import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { corsHeaders } from '../_shared/cors.ts';
import { supabaseAdmin } from '../_shared/supabase-client.ts';
import { anthropic } from '../_shared/anthropic-client.ts';

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  // Verify authentication
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response(
      JSON.stringify({ error: 'Missing authorization header' }),
      { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }

  try {
    const { patient_id, symptoms } = await req.json();

    if (!patient_id || !symptoms) {
      return new Response(
        JSON.stringify({ error: 'patient_id and symptoms are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Fetch patient demographics
    const { data: patient, error: patientError } = await supabaseAdmin
      .from('patients')
      .select('*')
      .eq('id', patient_id)
      .single();

    if (patientError) {
      throw new Error(`Failed to fetch patient: ${patientError.message}`);
    }

    // Fetch recent lab reports
    const { data: recentReports } = await supabaseAdmin
      .from('lab_reports')
      .select('*')
      .eq('patient_id', patient_id)
      .order('created_at', { ascending: false })
      .limit(5);

    // Fetch recent visits
    const { data: recentVisits } = await supabaseAdmin
      .from('visits')
      .select('*')
      .eq('patient_id', patient_id)
      .order('visited_at', { ascending: false })
      .limit(5);

    // Build patient context for Claude
    const patientContext = `
Patient Demographics:
- Name: ${patient.full_name || 'N/A'}
- Age: ${patient.date_of_birth ? calculateAge(patient.date_of_birth) : 'N/A'}
- Gender: ${patient.gender || 'N/A'}
- Blood Group: ${patient.blood_group || 'N/A'}
- Known Allergies: ${patient.allergies || 'None reported'}
- Existing Conditions: ${patient.chronic_conditions?.join(', ') || 'None reported'}

Recent Lab Reports (last 5):
${recentReports?.length ? recentReports.map((r: any) => `- ${r.report_type}: ${r.status} (${r.created_at})`).join('\n') : 'No recent reports'}

Recent Visits (last 5):
${recentVisits?.length ? recentVisits.map((v: any) => `- ${v.visited_at}: ${v.chief_complaint || 'General'} - ${v.diagnosis || 'Pending'}`).join('\n') : 'No recent visits'}
    `.trim();

    // Call Claude for symptom analysis
    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 2048,
      messages: [
        {
          role: 'user',
          content: `You are a medical AI assistant helping with symptom assessment. You do NOT diagnose — you help patients understand their symptoms and guide them on next steps.

Given the following patient context and reported symptoms, provide a structured assessment.

${patientContext}

Reported Symptoms:
${Array.isArray(symptoms) ? symptoms.join(', ') : symptoms}

Respond ONLY with valid JSON in this exact format:
{
  "recommendations": ["list of actionable recommendations"],
  "triage_level": "home_care | see_doctor | emergency",
  "what_to_do": ["list of things the patient should do"],
  "what_to_avoid": ["list of things the patient should avoid"],
  "when_to_seek_help": "description of warning signs that require immediate medical attention"
}`,
        },
      ],
    });

    // Extract the text response
    const responseText = message.content[0].type === 'text' ? message.content[0].text : '';
    let structuredResponse;

    try {
      structuredResponse = JSON.parse(responseText);
    } catch {
      // If Claude didn't return valid JSON, wrap the response
      structuredResponse = {
        recommendations: [responseText],
        triage_level: 'see_doctor',
        what_to_do: ['Consult a healthcare professional for proper evaluation'],
        what_to_avoid: ['Self-medicating without professional guidance'],
        when_to_seek_help: 'If symptoms worsen or new symptoms appear, seek immediate medical attention.',
      };
    }

    // Save the session to symptom_sessions table
    const { data: session, error: sessionError } = await supabaseAdmin
      .from('symptom_sessions')
      .insert({
        patient_id,
        symptoms_input: Array.isArray(symptoms) ? symptoms.join(', ') : symptoms,
        ai_response: structuredResponse,
        triage_level: structuredResponse.triage_level,
        created_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (sessionError) {
      console.error('Failed to save symptom session:', sessionError.message);
    }

    return new Response(
      JSON.stringify({
        session_id: session?.id ?? null,
        ...structuredResponse,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    console.error('ai-symptom error:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});

function calculateAge(dateOfBirth: string): number {
  const today = new Date();
  const birth = new Date(dateOfBirth);
  let age = today.getFullYear() - birth.getFullYear();
  const monthDiff = today.getMonth() - birth.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
    age--;
  }
  return age;
}
