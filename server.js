import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import Stripe from "stripe";
import bodyParser from "body-parser";

dotenv.config();

const app = express();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

/* -------------------------
   CORS + JSON (normal routes)
--------------------------*/
app.use(cors({
  origin: process.env.CLIENT_URL,
}));

app.use("/webhook", bodyParser.raw({ type: "application/json" }));
app.use(express.json());

/* -------------------------
   HEALTH CHECK
--------------------------*/
app.get("/", (req, res) => {
  res.send("AA backend running");
});

/* -------------------------
   CREATE STRIPE SESSION
--------------------------*/
app.post("/create-checkout-session", async (req, res) => {
  try {
    const { cart, email } = req.body;

    if (!cart || cart.length === 0) {
      return res.status(400).json({ error: "Cart is empty" });
    }

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      mode: "payment",
      customer_email: email,

      line_items: cart.map(item => ({
        price_data: {
          currency: "usd",
          product_data: {
            name: item.name,
          },
          unit_amount: Math.round(item.price * 100),
        },
        quantity: item.quantity,
      })),

      success_url: `${process.env.CLIENT_URL}/success.html`,
      cancel_url: `${process.env.CLIENT_URL}/cart.html`,
    });

    res.json({ url: session.url });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Checkout session failed" });
  }
});

/* -------------------------
   STRIPE WEBHOOK (SECURE CORE)
--------------------------*/
app.post("/webhook", (req, res) => {
  const sig = req.headers["stripe-signature"];

  let event;

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      endpointSecret
    );
  } catch (err) {
    console.log("Webhook signature failed:", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  /* -------------------------
     HANDLE EVENTS
  --------------------------*/

  if (event.type === "checkout.session.completed") {
    const session = event.data.object;

    console.log("💰 PAYMENT SUCCESSFUL:");
    console.log("Customer:", session.customer_email);
    console.log("Session ID:", session.id);

    // 🔥 THIS is where real order processing happens:
    // - save to database
    // - send email receipt
    // - fulfill order
  }

  res.json({ received: true });
});

/* -------------------------
   START SERVER
--------------------------*/
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});