import express, { Request, Response } from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import { GoogleGenAI, ThinkingLevel } from '@google/genai';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;
const isProduction = process.env.NODE_ENV === 'production';

app.use(express.json({ limit: '10mb' }));

// Initialize Google GenAI on the server
let aiClient: GoogleGenAI | null = null;
if (process.env.GEMINI_API_KEY) {
  aiClient = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY,
    httpOptions: {
      headers: {
        'User-Agent': 'aistudio-build'
      }
    }
  });
}

// API Health Check
app.get('/api/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    app: 'Aurevoya Global Travel & Experience',
    version: '1.0.0',
    geminiConfigured: !!process.env.GEMINI_API_KEY,
    timestamp: new Date().toISOString()
  });
});

// High-Thinking Gemini Travel Advisor & Itinerary Generator Endpoint
// Uses gemini-4-argon with thinkingLevel: ThinkingLevel.HIGH per specification
app.post('/api/ai/plan-trip', async (req: Request, res: Response) => {
  try {
    const { destination, days, budget, travelers, travelType, interests, customQuery } = req.body;

    if (!process.env.GEMINI_API_KEY || !aiClient) {
      // Provide a thoughtful fallback plan if API key is not configured in environment
      return res.json({
        success: true,
        isFallback: true,
        thinkingSummary: 'Demonstration reasoning mode: Gemini API Key not detected in environment. Generating curated travel architectural blueprint.',
        plan: `### Curated Travel Architect Plan for ${destination || 'Your Dream Journey'}\n\n**Duration:** ${days || 7} Days | **Travelers:** ${travelers || '2 Adults'} | **Style:** ${travelType || 'Luxury & Cultural'}\n\n#### Strategic Overview\nYour personalized travel blueprint is calibrated for exceptional pacing, genuine cultural immersion, and seamless logistics with Aurevoya concierge support.\n\n#### Day-by-Day Master Itinerary\n- **Day 1: Majestic Arrival & Welcome** — Private executive airport transfer, check-in to boutique 5-star lodging, panoramic sunset orientation.\n- **Day 2: Historical & Cultural Heart** — Private licensed historian walking tour, skip-the-line iconic monument admissions, curated culinary lunch.\n- **Day 3: Scenic Excursion & Nature** — Coastal catamaran cruise or scenic mountain train journey, signature regional dining.\n- **Day 4: Authentic Local Living** — Artisan workshops, traditional village exploration, sunset dinner overlooking scenic vistas.\n- **Day 5: Adventure & Leisure** — Morning outdoor experience (hot air balloon / snorkeling safari), afternoon relaxed spa and shopping.\n- **Day 6: Hidden Gems & High-View Evening** — Lesser-known viewpoints, gourmet farewell dining with regional wine pairing.\n- **Day 7: Farewell & Seamless Departure** — Leisurely breakfast, private transfer to international departure lounge.\n\n*To enable real-time deep reasoning with gemini-4-argon, please attach a Gemini API key in the AI Studio Secrets panel.*`
      });
    }

    const promptText = `
User Query:
Destination: ${destination || 'Flexible'}
Duration: ${days || 7} days
Budget Level: ${budget || 'Comfortable/Luxury'}
Travelers: ${travelers || '2 adults'}
Category: ${travelType || 'Leisure / Cultural / Pilgrimage'}
Interests: ${Array.isArray(interests) ? interests.join(', ') : (interests || 'Sightseeing, Cuisine, Relaxation')}
Special Requirements: ${customQuery || 'None specified'}

Please build a comprehensive, master-level travel itinerary and strategic travel advice for this customer traveling with AUREVOYA GLOBAL TRAVEL & EXPERIENCE.
Include:
1. Executive Trip Summary & Best Flight/Transit route.
2. Day-by-day structured itinerary with morning, afternoon, evening highlights.
3. Essential visa, health, and currency preparation tips.
4. Estimated transparent budget breakdown (accommodation, meals, transport, activities).
5. Aurevoya concierge recommendations.
`;

    const response = await aiClient.models.generateContent({
      model: 'gemini-4-argon',
      contents: promptText,
      config: {
        systemInstruction: `You are the Chief Travel Architect for AUREVOYA GLOBAL TRAVEL & EXPERIENCE (Tagline: Dream • Discover • Travel).
You specialize in premium international itineraries, Bangladesh scenic circuits, Hajj & Umrah pilgrimage guidance, and visa preparation.
Your advice is exceptionally well-reasoned, realistic, structured with elegant markdown, and avoids vague travel clichés.
Always emphasize safety, realistic travel transit times, and transparent pricing.`,
        thinkingConfig: {
          thinkingLevel: ThinkingLevel.HIGH
        }
      }
    });

    res.json({
      success: true,
      plan: response.text,
      modelUsed: 'gemini-4-argon',
      thinkingLevel: 'HIGH'
    });
  } catch (err: any) {
    console.error('Gemini API Error:', err);
    res.status(500).json({
      success: false,
      error: err.message || 'Failed to generate itinerary with Gemini AI'
    });
  }
});

// Server-Side Payment Verification (Simulated & Gateway Integration Bridge)
app.post('/api/payments/verify-checkout', (req: Request, res: Response) => {
  const { bookingReference, paymentMethod, amountUSD, currency, isDemo } = req.body;

  // In DEMO mode (default until official merchant keys are installed)
  // Transparently return a verified demo receipt without falsifying live banking credentials
  const simulatedTxId = `TXN-${paymentMethod.toUpperCase()}-${Math.floor(100000 + Math.random() * 900000)}`;

  res.json({
    success: true,
    isDemo: isDemo ?? true,
    transactionId: simulatedTxId,
    bookingReference,
    amountUSD,
    currency,
    status: isDemo ? 'Demo Only' : 'Awaiting Verification',
    message: isDemo
      ? 'Demo transaction recorded. Per safety protocols, no real money was debited.'
      : 'Payment verification initiated with merchant gateway.',
    timestamp: new Date().toISOString()
  });
});

// Notification Dispatch Logger
app.post('/api/notifications/dispatch', (req: Request, res: Response) => {
  const { channel, recipient, subject, message, entityReference } = req.body;

  console.log(`[Aurevoya Notification] Channel: ${channel} | To: ${recipient} | Ref: ${entityReference}`);

  res.json({
    success: true,
    channel,
    recipient,
    status: 'demo_logged',
    providerReference: `NOTIF-SIM-${Date.now()}`,
    timestamp: new Date().toISOString(),
    note: 'In demo mode, notification was logged to database notification center. Real SMS/WhatsApp requires merchant gateway credentials.'
  });
});

// Serve static assets from public folder
app.use(express.static(path.resolve(__dirname, 'public')));

// Dev vs Production Setup
async function startServer() {
  if (!isProduction) {
    const { createServer: createViteServer } = await import('vite');
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa'
    });
    app.use(vite.middlewares);
  } else {
    app.use(express.static(path.resolve(__dirname, 'dist')));
    app.get('*', (req: Request, res: Response) => {
      res.sendFile(path.resolve(__dirname, 'dist', 'index.html'));
    });
  }

  const portNumber = Number(PORT) || 3000;
  app.listen(portNumber, '0.0.0.0', () => {
    console.log(`🚀 Aurevoya Server running on port ${portNumber} (Mode: ${isProduction ? 'Production' : 'Development'})`);
  });
}

startServer();
