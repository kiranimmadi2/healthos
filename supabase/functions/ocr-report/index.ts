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
    const { report_url, patient_id, report_id } = await req.json();

    if (!report_url || !patient_id || !report_id) {
      return new Response(
        JSON.stringify({ error: 'report_url, patient_id, and report_id are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Download the report image from Supabase Storage
    const { data: fileData, error: downloadError } = await supabaseAdmin
      .storage
      .from('reports')
      .download(report_url);

    if (downloadError) {
      throw new Error(`Failed to download report: ${downloadError.message}`);
    }

    // Convert the file to base64
    const arrayBuffer = await fileData.arrayBuffer();
    const base64Image = btoa(
      new Uint8Array(arrayBuffer).reduce((data, byte) => data + String.fromCharCode(byte), ''),
    );

    // Determine media type from the URL
    const extension = report_url.split('.').pop()?.toLowerCase();
    let mediaType = 'image/jpeg';
    if (extension === 'png') mediaType = 'image/png';
    else if (extension === 'pdf') mediaType = 'application/pdf';
    else if (extension === 'webp') mediaType = 'image/webp';
    else if (extension === 'gif') mediaType = 'image/gif';

    // Call Claude Vision API to extract biomarker values
    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 4096,
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'image',
              source: {
                type: 'base64',
                media_type: mediaType,
                data: base64Image,
              },
            },
            {
              type: 'text',
              text: `You are a medical lab report OCR assistant. Extract ALL biomarker/test values from this lab report image.

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
}`,
            },
          ],
        },
      ],
    });

    // Extract the text response
    const responseText = message.content[0].type === 'text' ? message.content[0].text : '';
    let extractedData;

    try {
      extractedData = JSON.parse(responseText);
    } catch {
      throw new Error('Failed to parse OCR response from Claude');
    }

    // Insert extracted biomarkers into the biomarkers table
    if (extractedData.biomarkers && extractedData.biomarkers.length > 0) {
      const biomarkerRecords = extractedData.biomarkers.map((b: any) => ({
        patient_id,
        report_id,
        name: b.name,
        value: b.value,
        unit: b.unit,
        reference_min: b.reference_min,
        reference_max: b.reference_max,
        status: b.status,
        recorded_at: extractedData.report_date || new Date().toISOString(),
      }));

      const { error: insertError } = await supabaseAdmin
        .from('biomarkers')
        .insert(biomarkerRecords);

      if (insertError) {
        console.error('Failed to insert biomarkers:', insertError.message);
      }
    }

    // Update lab_report status to 'ready'
    const { error: updateError } = await supabaseAdmin
      .from('lab_reports')
      .update({
        status: 'ready',
        report_type: extractedData.report_type || null,
        lab_name: extractedData.lab_name || null,
        processed_at: new Date().toISOString(),
      })
      .eq('id', report_id);

    if (updateError) {
      console.error('Failed to update report status:', updateError.message);
    }

    return new Response(
      JSON.stringify({
        success: true,
        report_id,
        ...extractedData,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    console.error('ocr-report error:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
