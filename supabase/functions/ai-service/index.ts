/**
 * AI Microservice
 *
 * Unified AI service consolidating all AI-powered operations:
 * - Symptom assessment and triage
 * - Patient health summary generation
 * - Lab report OCR (vision-based extraction)
 * - Symptom session history
 *
 * Routes:
 *   POST   /symptoms              → Symptom check + triage
 *   POST   /summary               → Generate patient health summary
 *   POST   /ocr                   → OCR a lab report image
 *   GET    /sessions/:patientId   → Symptom session history
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { Router } from '../_shared/router.ts';
import { createServiceHandler, requireAuth, json, errorResponse } from '../_shared/middleware.ts';
import { supabaseAdmin } from '../_shared/supabase-client.ts';
import { genAI } from '../_shared/gemini-client.ts';

const router = new Router();

// ─── Helpers ────────────────────────────────────────────────

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

function parseJsonResponse(text: string, fallback: Record<string, unknown>): Record<string, unknown> {
  try {
    return JSON.parse(text);
  } catch {
    return fallback;
  }
}

// ─── Symptom Assessment ─────────────────────────────────────

router.post('/symptoms', requireAuth(async (ctx) => {
  const body = await ctx.body<{ patient_id: string; symptoms: string[] | string }>();

  if (!body.patient_id || !body.symptoms) {
    return errorResponse('patient_id and symptoms are required');
  }

  // Fetch patient context
  const { data: patient, error: patientError } = await supabaseAdmin
    .from('patients')
    .select('*')
    .eq('id', body.patient_id)
    .single();

  if (patientError) return errorResponse(`Patient not found: ${patientError.message}`, 404);

  const { data: recentReports } = await supabaseAdmin
    .from('lab_reports')
    .select('*')
    .eq('patient_id', body.patient_id)
    .order('created_at', { ascending: false })
    .limit(5);

  const { data: recentVisits } = await supabaseAdmin
    .from('visits')
    .select('*')
    .eq('patient_id', body.patient_id)
    .order('visited_at', { ascending: false })
    .limit(5);

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

  const prompt = `You are a medical AI assistant helping with symptom assessment. You do NOT diagnose — you help patients understand their symptoms and guide them on next steps.

Given the following patient context and reported symptoms, provide a structured assessment.

${patientContext}

Reported Symptoms:
${Array.isArray(body.symptoms) ? body.symptoms.join(', ') : body.symptoms}

Respond ONLY with valid JSON in this exact format:
{
  "recommendations": ["list of actionable recommendations"],
  "triage_level": "see_doctor",
  "what_to_do": ["list of things the patient should do"],
  "what_to_avoid": ["list of things the patient should avoid"],
  "when_to_seek_help": "description of warning signs that require immediate medical attention"
}`;

  const model = genAI.getGenerativeModel({
    model: 'gemini-1.5-flash',
    generationConfig: { responseMimeType: "application/json" }
  });

  const result = await model.generateContent(prompt);
  const responseText = result.response.text();
  const structuredResponse = parseJsonResponse(responseText, {
    recommendations: [responseText],
    triage_level: 'see_doctor',
    what_to_do: ['Consult a healthcare professional for proper evaluation'],
    what_to_avoid: ['Self-medicating without professional guidance'],
    when_to_seek_help: 'If symptoms worsen or new symptoms appear, seek immediate medical attention.',
  });

  // Save session
  const { data: session, error: sessionError } = await supabaseAdmin
    .from('symptom_sessions')
    .insert({
      patient_id: body.patient_id,
      symptoms_input: Array.isArray(body.symptoms) ? body.symptoms.join(', ') : body.symptoms,
      ai_response: structuredResponse,
      triage_level: structuredResponse.triage_level,
      created_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (sessionError) console.error('Failed to save symptom session:', sessionError.message);

  return json({ session_id: session?.id ?? null, ...structuredResponse });
}));

// ─── Patient Health Summary ─────────────────────────────────

router.post('/summary', requireAuth(async (ctx) => {
  const body = await ctx.body<{ patient_id: string }>();

  if (!body.patient_id) return errorResponse('patient_id is required');

  // Fetch comprehensive patient data
  const { data: patient, error: patientError } = await supabaseAdmin
    .from('patients')
    .select('*')
    .eq('id', body.patient_id)
    .single();

  if (patientError) return errorResponse(`Patient not found: ${patientError.message}`, 404);

  const [visits, reports, prescriptions, biomarkers] = await Promise.all([
    supabaseAdmin.from('visits').select('*').eq('patient_id', body.patient_id)
      .order('visited_at', { ascending: false }).limit(50),
    supabaseAdmin.from('lab_reports').select('*').eq('patient_id', body.patient_id)
      .order('created_at', { ascending: false }).limit(50),
    supabaseAdmin.from('prescriptions').select('*').eq('patient_id', body.patient_id)
      .order('created_at', { ascending: false }).limit(50),
    supabaseAdmin.from('biomarkers').select('*').eq('patient_id', body.patient_id)
      .order('recorded_at', { ascending: false }).limit(50),
  ]);

  const patientContext = `
Patient Demographics:
- Name: ${patient.full_name || 'N/A'}
- Age: ${patient.date_of_birth ? calculateAge(patient.date_of_birth) : 'N/A'}
- Gender: ${patient.gender || 'N/A'}
- Blood Group: ${patient.blood_group || 'N/A'}
- Known Allergies: ${patient.allergies || 'None reported'}
- Existing Conditions: ${patient.chronic_conditions?.join(', ') || 'None reported'}

Visit History (${visits.data?.length || 0} visits):
${visits.data?.length ? visits.data.map((v: any) => `- ${v.visited_at}: Complaint: ${v.chief_complaint || 'General'} | Diagnosis: ${v.diagnosis || 'N/A'} | Notes: ${v.notes || 'N/A'}`).join('\n') : 'No visits recorded'}

Lab Reports (${reports.data?.length || 0} reports):
${reports.data?.length ? reports.data.map((r: any) => `- ${r.created_at}: ${r.report_type} | Status: ${r.status} | Notes: ${r.notes || 'N/A'}`).join('\n') : 'No reports recorded'}

Prescriptions (${prescriptions.data?.length || 0} prescriptions):
${prescriptions.data?.length ? prescriptions.data.map((p: any) => `- ${p.issued_at}: ${(p.medications || []).map((m: any) => `${m.name} ${m.dose} (${m.frequency})`).join(', ')} | Notes: ${p.notes || 'N/A'}`).join('\n') : 'No prescriptions recorded'}

Biomarkers (${biomarkers.data?.length || 0} readings):
${biomarkers.data?.length ? biomarkers.data.map((b: any) => `- ${b.name}: ${b.value} ${b.unit} (Ref: ${b.normal_min ?? '?'}-${b.normal_max ?? '?'}) ${b.is_abnormal ? '[ABNORMAL]' : ''} | ${b.recorded_at}`).join('\n') : 'No biomarkers recorded'}
  `.trim();

  const prompt = `You are a medical AI assistant generating a comprehensive patient health summary for healthcare providers.

Analyze the following patient data and provide a structured summary.

${patientContext}

Respond ONLY with valid JSON in this exact format:
{
  "summary": "A concise 2-3 paragraph narrative summary of the patient's overall health status and history",
  "key_findings": ["list of important clinical findings from their data"],
  "risk_factors": ["list of identified risk factors based on demographics, history, and biomarkers"],
  "recommendations": ["list of recommended next steps, screenings, or lifestyle changes"]
}`;

  const model = genAI.getGenerativeModel({
    model: 'gemini-1.5-flash',
    generationConfig: { responseMimeType: "application/json" }
  });

  const result = await model.generateContent(prompt);
  const responseText = result.response.text();
  const structuredResponse = parseJsonResponse(responseText, {
    summary: responseText,
    key_findings: [],
    risk_factors: [],
    recommendations: ['Unable to parse structured data. Please review the summary text.'],
  });

  return json(structuredResponse);
}));

// ─── Lab Report OCR ─────────────────────────────────────────

router.post('/ocr', requireAuth(async (ctx) => {
  const body = await ctx.body<{ report_url: string; patient_id: string; report_id: string }>();

  if (!body.report_url || !body.patient_id || !body.report_id) {
    return errorResponse('report_url, patient_id, and report_id are required');
  }

  // Download the report image from Supabase Storage
  const { data: fileData, error: downloadError } = await supabaseAdmin
    .storage
    .from('reports')
    .download(body.report_url);

  if (downloadError) return errorResponse(`Failed to download report: ${downloadError.message}`, 500);

  // Convert to base64
  const arrayBuffer = await fileData.arrayBuffer();
  const base64Image = btoa(
    new Uint8Array(arrayBuffer).reduce((data, byte) => data + String.fromCharCode(byte), ''),
  );

  // Determine media type
  const extension = body.report_url.split('.').pop()?.toLowerCase();
  let mediaType = 'image/jpeg';
  if (extension === 'png') mediaType = 'image/png';
  else if (extension === 'pdf') mediaType = 'application/pdf';
  else if (extension === 'webp') mediaType = 'image/webp';
  else if (extension === 'gif') mediaType = 'image/gif';

  const prompt = `You are a medical lab report OCR assistant. Extract ALL biomarker/test values from this lab report image.

For each biomarker found, extract:
- name: The test/biomarker name (e.g., "Hemoglobin", "Blood Glucose", "TSH")
- value: The numeric value
- unit: The unit of measurement (e.g., "g/dL", "mg/dL", "mIU/L")
- reference_min: Lower bound of the reference range (null if not shown)
- reference_max: Upper bound of the reference range (null if not shown)
- status: "normal", "low", or "high" based on the reference range

Respond ONLY with valid JSON in this exact format:
{
  "report_type": "Type of report (e.g., Complete Blood Count, Lipid Panel, Thyroid Panel)",
  "lab_name": "Name of the laboratory if visible",
  "report_date": "Date on the report if visible (YYYY-MM-DD format)",
  "biomarkers": [
    {
      "name": "Biomarker Name",
      "value": 12.5,
      "unit": "g/dL",
      "reference_min": 12.0,
      "reference_max": 16.0,
      "status": "normal"
    }
  ]
}`;

  const model = genAI.getGenerativeModel({
    model: 'gemini-1.5-pro',
    generationConfig: { responseMimeType: "application/json" }
  });

  const imagePart = {
    inlineData: {
      data: base64Image,
      mimeType: mediaType
    }
  };

  const result = await model.generateContent([prompt, imagePart]);
  const responseText = result.response.text();
  let extractedData;
  try {
    extractedData = JSON.parse(responseText);
  } catch {
    return errorResponse('Failed to parse OCR response from Gemini', 500);
  }

  // Insert biomarkers into database
  if (extractedData.biomarkers?.length > 0) {
    const biomarkerRecords = extractedData.biomarkers.map((b: any) => ({
      patient_id: body.patient_id,
      report_id: body.report_id,
      name: b.name,
      value: b.value,
      unit: b.unit,
      normal_min: b.reference_min,
      normal_max: b.reference_max,
      recorded_at: extractedData.report_date || new Date().toISOString(),
    }));

    const { error: insertError } = await supabaseAdmin
      .from('biomarkers')
      .insert(biomarkerRecords);

    if (insertError) console.error('Failed to insert biomarkers:', insertError.message);
  }

  // Update lab_report status
  const { error: updateError } = await supabaseAdmin
    .from('lab_reports')
    .update({
      status: 'ready',
      report_type: extractedData.report_type || null,
      lab_name: extractedData.lab_name || null,
    })
    .eq('id', body.report_id);

  if (updateError) console.error('Failed to update report status:', updateError.message);

  return json({ success: true, report_id: body.report_id, ...extractedData });
}));

// ─── Symptom Session History ────────────────────────────────

router.get('/sessions/:patientId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '20');
  const offset = parseInt(ctx.query.get('offset') || '0');

  const { data, error, count } = await supabaseAdmin
    .from('symptom_sessions')
    .select('*', { count: 'exact' })
    .eq('patient_id', ctx.params.patientId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

// ─── Start service ──────────────────────────────────────────

serve(createServiceHandler(router));
