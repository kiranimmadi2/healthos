import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { corsHeaders } from '../_shared/cors.ts';
import { supabaseAdmin } from '../_shared/supabase-client.ts';
import { anthropic } from '../_shared/anthropic-client.ts';

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { patient_id } = await req.json();

    if (!patient_id) {
      return new Response(
        JSON.stringify({ error: 'patient_id is required' }),
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

    // Fetch all visits
    const { data: visits } = await supabaseAdmin
      .from('visits')
      .select('*')
      .eq('patient_id', patient_id)
      .order('visit_date', { ascending: false });

    // Fetch all lab reports
    const { data: reports } = await supabaseAdmin
      .from('lab_reports')
      .select('*')
      .eq('patient_id', patient_id)
      .order('created_at', { ascending: false });

    // Fetch all prescriptions
    const { data: prescriptions } = await supabaseAdmin
      .from('prescriptions')
      .select('*')
      .eq('patient_id', patient_id)
      .order('created_at', { ascending: false });

    // Fetch all biomarkers
    const { data: biomarkers } = await supabaseAdmin
      .from('biomarkers')
      .select('*')
      .eq('patient_id', patient_id)
      .order('recorded_at', { ascending: false });

    // Build comprehensive patient context
    const patientContext = `
Patient Demographics:
- Name: ${patient.full_name || 'N/A'}
- Age: ${patient.date_of_birth ? calculateAge(patient.date_of_birth) : 'N/A'}
- Gender: ${patient.gender || 'N/A'}
- Blood Group: ${patient.blood_group || 'N/A'}
- Known Allergies: ${patient.allergies || 'None reported'}
- Existing Conditions: ${patient.conditions || 'None reported'}

Visit History (${visits?.length || 0} visits):
${visits?.length ? visits.map((v: any) => `- ${v.visit_date}: Reason: ${v.reason || 'General'} | Diagnosis: ${v.diagnosis || 'N/A'} | Notes: ${v.notes || 'N/A'}`).join('\n') : 'No visits recorded'}

Lab Reports (${reports?.length || 0} reports):
${reports?.length ? reports.map((r: any) => `- ${r.created_at}: ${r.report_type} | Status: ${r.status} | Notes: ${r.notes || 'N/A'}`).join('\n') : 'No reports recorded'}

Prescriptions (${prescriptions?.length || 0} prescriptions):
${prescriptions?.length ? prescriptions.map((p: any) => `- ${p.medication_name}: ${p.dosage} | Frequency: ${p.frequency} | Status: ${p.status || 'active'}`).join('\n') : 'No prescriptions recorded'}

Biomarkers (${biomarkers?.length || 0} readings):
${biomarkers?.length ? biomarkers.map((b: any) => `- ${b.name}: ${b.value} ${b.unit} (Ref: ${b.reference_min ?? '?'}-${b.reference_max ?? '?'}) | ${b.recorded_at}`).join('\n') : 'No biomarkers recorded'}
    `.trim();

    // Call Claude for summary generation
    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 3000,
      messages: [
        {
          role: 'user',
          content: `You are a medical AI assistant generating a comprehensive patient health summary for healthcare providers.

Analyze the following patient data and provide a structured summary.

${patientContext}

Respond ONLY with valid JSON in this exact format:
{
  "summary": "A concise 2-3 paragraph narrative summary of the patient's overall health status and history",
  "key_findings": ["list of important clinical findings from their data"],
  "risk_factors": ["list of identified risk factors based on demographics, history, and biomarkers"],
  "recommendations": ["list of recommended next steps, screenings, or lifestyle changes"]
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
      structuredResponse = {
        summary: responseText,
        key_findings: [],
        risk_factors: [],
        recommendations: ['Unable to parse structured data. Please review the summary text.'],
      };
    }

    return new Response(
      JSON.stringify(structuredResponse),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    console.error('ai-summary error:', error);
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
