require('dotenv').config();

const express = require('express');
const cors = require('cors');
const Stripe = require('stripe');

const app = express();
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'Stripe backend radi.',
  });
});

app.post('/create-payment-intent', async (req, res) => {
  try {
    const { amount, currency = 'eur' } = req.body;

    if (!Number.isInteger(amount) || amount <= 0) {
      return res.status(400).json({
        error: 'Iznos mora biti pozitivan cijeli broj.',
      });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: {
        enabled: true,
      },
    });

    return res.status(200).json({
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    console.error('Stripe greška:', error);

    return res.status(500).json({
      error: error.message ?? 'Greška pri kreiranju plaćanja.',
    });
  }
});

const PORT = 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Stripe server radi na portu ${PORT}.`);
});