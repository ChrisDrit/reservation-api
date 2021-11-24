# [Hometime](https://hometime.io)

## Ruby on Rails Engineer Skill Assessment

### Background

Hometime integrates with multiple partners in our industry. Across these partners, we typically receive the same data formatted in different ways. For example, the reservation payload we receive from Airbnb, is different from the reservation payload from Booking.com. The core skills we look for in a Ruby on Rails Engineer is their ability to work with APIs. We’d like you to demonstrate how you would parse and save 2 different payloads with 1 API endpoint.

### Instructions

1. Start a Ruby on Rails project that is purely an API app.
2. Create one API endpoint that can accept both payload formats. See payloads
at the end of this document.
3. Your code should not require any additional headers or parameters to distinguish between the 2 payloads.
4. Parse and save the payloads to a Reservation model that belongs to a Guest model. Reservation code and guest email field should be unique.
5. API should be able accept changes to the reservation. e.g., change in status, check-in/out dates, number of guests, etc...
6. Add a README file to the root of your repository with clear instructions on how to set up and run your app.
7. Your submission should be available in a public git repository of your choice. Alternatively, you can submit a zipped folder of your source code.

### Expectations

1. Readable and maintainable code - use your preferred convention on separating the different logics, and put them in their appropriate places.
2. Scalable code - your code must demonstrate a clear path forward in the event a third payload is introduced.
3. Use of standard practices - treat your submission as production ready. We’ll look for proper error handling, tests, clear documentation, etc...

### Payloads

**Payload #1**

```
{
"reservation_code": "YYY12345678", "start_date": "2021-04-14", "end_date": "2021-04-18", "nights": 4,
"guests": 4,
"adults": 2,
"children": 2,
"infants": 0,
"status": "accepted",
"guest": {
"first_name": "Wayne", "last_name": "Woodbridge", "phone": "639123456789",
"email": "wayne_woodbridge@bnb.com"
},
"currency": "AUD", "payout_price": "4200.00", "security_price": "500", "total_price": "4700.00"
}
```

**Payload #2**

```
{
"reservation": {
"code": "XXX12345678",
"start_date": "2021-03-12", "end_date": "2021-03-16", "expected_payout_amount": "3800.00", "guest_details": {
"localized_description": "4 guests", "number_of_adults": 2, "number_of_children": 2, "number_of_infants": 0
},
"guest_email": "wayne_woodbridge@bnb.com", "guest_first_name": "Wayne", "guest_last_name": "Woodbridge", "guest_phone_numbers": [
"639123456789",
"639123456789"
],
"listing_security_price_accurate": "500.00", "host_currency": "AUD",
"nights": 4,
"number_of_guests": 4,
"status_type": "accepted", "total_paid_amount_accurate": "4300.00"
} }
```