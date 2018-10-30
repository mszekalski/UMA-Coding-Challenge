# README

## How To Run

Git clone this repository, navigate to the folder and run the following commands.
```
bundle install
rails db:create
bundle exec rspec
```
The rspec tests will run, everything should pass

## Overview and Structure

The goals as laid out in the instructions were the following.

- Create Doctor and Appointment models
- Have the following methods on the Doctor model
  - Creating an Appointment 
  - Deleting an Appointment
  - Returning availbility of the doctor given a day
  
For my database, I used a PostgreSQL. To see my database schema decisions, please see `db/schema.rb`. One thing of note, I chose to represent appointments with `appointment_time` and `duration` rather than `start_time` and `end_time`. I chose this to more easily enforce hour-long appointments. In addition, all columns have `null: false` constraints to enforce presence on the db. 

In my Appoinment model, I added four custom validations:
 - Validating that the appointment falls between 9AM and 5PM
 - Validating that the appointment has been created in the future and not the past
 - Validating that there are no overlapping appointments
 - Validating that the appointment is not on the weekend
 
These model level validations, along with my database design, ensured that the data my application is taking in is of the correct type, as well as structured correctly. 

## Models

#### Doctor

Of note in the Doctor model is the availbile_appointments method.

##### availible_appointments

The availible_appointments method is used to return a user friendly readout of the doctor's availbility on a certain date. The method could easily be converted to also return time ranges in an array, that could be used elsewhere to determine if an appointment overlaps with another appointment on that date. 

#### Appointment

The Appointment model has convenience methods for returning formatted and manipulated versions of the DateTime variable for use elsewhere. In these methods I relied heavily on ruby's .strftime as well as .change, to create necessary data transformations.

## Thoughts and Challenges

#### Time Zones

I think this is the biggest functionality I didn't address in my application. While not an issue currently, if this app went into production it's something I'd have to correct. It would involve doing some additional conversions when receiving data from the user and when returning data to the potential frontend. 

#### Testing

There'a few minor flaws in my testing as it's currently set up. I am using hard-coded dates that will cause spec failures when run in the future. As time goes on, these tests will not act properly because the date I've chosen will eventually become the past and the appointments will no longer be valid. From my research I discovered a ruby gem called Timecop that I could use to alleviate this problem by freezing the DateTime in a test file.

#### Delegation of Responsiblities

The biggest technical challenge in designing the two models was thoughtfully delegating responsibilities. Both the Doctor and Appointment model make an effort to encapsulate repsonsbility, although in the Appointment#not_overlapped? method I found it necessary to get information from the Doctor model. 
