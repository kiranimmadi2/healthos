import { GoogleGenerativeAI } from 'https://esm.sh/@google/generative-ai@0.21.0';

const apiKey = Deno.env.get('GEMINI_API_KEY');
if (!apiKey) throw new Error('GEMINI_API_KEY environment variable is not set');
export const genAI = new GoogleGenerativeAI(apiKey);
