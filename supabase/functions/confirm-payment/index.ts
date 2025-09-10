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
    const { payment_intent_id, customer_id } = await req.json()

    // Validate input
    if (!payment_intent_id || !customer_id) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Retrieve PaymentIntent from Stripe to verify status
    const paymentIntent = await stripe.paymentIntents.retrieve(payment_intent_id)

    if (paymentIntent.status !== 'succeeded') {
      return new Response(
        JSON.stringify({ 
          error: 'Payment not completed',
          status: paymentIntent.status 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Get the PaymentIntent record from database
    const { data: paymentIntentRecord, error: fetchError } = await supabase
      .from('payment_intents')
      .select('*')
      .eq('stripe_payment_intent_id', payment_intent_id)
      .single()

    if (fetchError || !paymentIntentRecord) {
      return new Response(
        JSON.stringify({ error: 'Payment intent not found in database' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Create payment record
    const paymentData = {
      id: crypto.randomUUID(),
      order_id: paymentIntentRecord.order_id,
      payment_intent_id: paymentIntentRecord.id,
      customer_id,
      amount: paymentIntentRecord.amount,
      currency: paymentIntentRecord.currency,
      status: 'paid',
      provider: 'Stripe',
      external_transaction_id: payment_intent_id,
      payment_method_snapshot: {
        id: paymentIntent.payment_method,
        type: 'card', // Default to card for now
      },
      metadata: paymentIntentRecord.metadata || {},
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    }

    // Insert payment record
    const { data: payment, error: paymentError } = await supabase
      .from('payments')
      .insert(paymentData)
      .select()
      .single()

    if (paymentError) {
      console.error('Database error creating payment:', paymentError)
      return new Response(
        JSON.stringify({ error: 'Failed to create payment record' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Update order status to paid
    const { error: orderUpdateError } = await supabase
      .from('orders')
      .update({ 
        payment_status: 'paid',
        order_status: 'accepted', // Move to next status after payment
        updated_at: new Date().toISOString()
      })
      .eq('id', paymentIntentRecord.order_id)

    if (orderUpdateError) {
      console.error('Error updating order status:', orderUpdateError)
      // Don't fail the payment confirmation, but log the error
    }

    // Update payment intent status
    await supabase
      .from('payment_intents')
      .update({ 
        status: paymentIntent.status,
        updated_at: new Date().toISOString()
      })
      .eq('id', paymentIntentRecord.id)

    return new Response(
      JSON.stringify({
        id: payment.id,
        order_id: payment.order_id,
        amount: {
          amount: payment.amount,
          currency: payment.currency,
        },
        currency: payment.currency,
        status: payment.status,
        external_transaction_id: payment.external_transaction_id,
        payment_method: payment.payment_method_snapshot,
        metadata: payment.metadata,
        created_at: payment.created_at,
        updated_at: payment.updated_at,
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Error confirming payment:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
