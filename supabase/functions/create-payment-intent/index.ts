import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14.21.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Stripe
    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') || '', {
      apiVersion: '2023-10-16',
    })

    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    // Get request body
    const { amount, currency, customer_id, order_id, metadata } = await req.json()

    // Validate input
    if (!amount || !currency || !customer_id || !order_id) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Create or get Stripe customer
    let stripeCustomerId: string
    
    // Check if customer already has a Stripe customer ID
    const { data: existingCustomer } = await supabase
      .from('user_profiles')
      .select('stripe_customer_id')
      .eq('id', customer_id)
      .single()

    if (existingCustomer?.stripe_customer_id) {
      stripeCustomerId = existingCustomer.stripe_customer_id
    } else {
      // Create new Stripe customer
      const { data: userProfile } = await supabase
        .from('user_profiles')
        .select('email, full_name')
        .eq('id', customer_id)
        .single()

      const stripeCustomer = await stripe.customers.create({
        email: userProfile?.email,
        name: userProfile?.full_name,
        metadata: {
          supabase_user_id: customer_id,
        },
      })

      stripeCustomerId = stripeCustomer.id

      // Save Stripe customer ID to user profile
      await supabase
        .from('user_profiles')
        .update({ stripe_customer_id: stripeCustomerId })
        .eq('id', customer_id)
    }

    // Create PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount), // Ensure integer amount in cents
      currency: currency.toLowerCase(),
      customer: stripeCustomerId,
      metadata: {
        order_id,
        customer_id,
        ...metadata,
      },
      automatic_payment_methods: {
        enabled: true,
      },
    })

    // Save PaymentIntent to database
    const { error: dbError } = await supabase
      .from('payment_intents')
      .insert({
        id: paymentIntent.id,
        order_id,
        customer_id,
        amount: amount / 100, // Store as decimal in database
        currency: currency.toUpperCase(),
        status: paymentIntent.status,
        client_secret: paymentIntent.client_secret,
        stripe_payment_intent_id: paymentIntent.id,
        metadata,
      })

    if (dbError) {
      console.error('Database error:', dbError)
      return new Response(
        JSON.stringify({ error: 'Failed to save payment intent to database' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Return PaymentIntent
    return new Response(
      JSON.stringify({
        id: paymentIntent.id,
        client_secret: paymentIntent.client_secret,
        status: paymentIntent.status,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Error creating payment intent:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
