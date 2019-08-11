 document.addEventListener("DOMContentLoaded", function() {
   // Quotes
 const quotes = [{
      quote: "So glad I signed up! Saves me time, money and stress.",
      name: "Fred Bloggs"
    },
    {
      quote: "myBookingSherpa allows me to concerntrate on what I am best at and that's guiding.",
      name: "James Tyson"
    },
    {
      quote: "My bookings have gone up and my guests are happy.",
      name: "Roger Smith"
    },
    {
      quote: "I hate doing paperwork, myBookingSherpa takes care of so much of what I put off.",
      name: "Emily Jones"
    },
    {
      quote: "Online payments are now a breeze. The guests find it simple and quick.",
      name: "Jack Jones"
    },
    {
      quote: "I feel my business is much more organised. Giving me more time.",
      name: "Jane Thompson"
    },
    {
      quote: "myBookingSherpa simplified group bookings for my trekking business. Allowing me to take on bigger groups.",
      name: "Naomi Best"
    }
  ];
  
  // Get random quote and display 

  const randomNumber = Math.floor(Math.random() * quotes.length);
  const quoteMessage = quotes[randomNumber].quote;
  const nameText = quotes[randomNumber].name;
  const quoteTextLocation = document.querySelector('.quote-text');
  const nameTextLocation = document.querySelector('.blog-post-bottom');
  if (!quoteTextLocation || !nameTextLocation) return;
  quoteTextLocation.innerHTML = quoteMessage;
  nameTextLocation.innerHTML = nameText;
});