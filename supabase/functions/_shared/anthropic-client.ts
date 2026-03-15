import Anthropic from 'https://esm.sh/@anthropic-ai/sdk@0.32.1';

export const anthropic = new Anthropic({
  apiKey: Deno.env.get('ANTHROPIC_API_KEY'),
});
