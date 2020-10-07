General Overview

We are planning to make an application that will guide students and visitors around Duke life. It aims to help people not only assimilate to Duke life, but also grow out of their bubble and take advantage of all the places Durham has to offer. Our app will include a map of not only places on campus, but also the greater Durham area. Users will be able to search for restaurants, study spaces, coffee shops, shopping places, bars, hikes, and routes to walk or run. Our application will display a map with pins that correspond to the user’s search query. Within each pin, users can view details about places, comments and reviews from students, and pictures posted by students. Duke students will be able to log onto our application with their “duke.edu” accounts. As a student, users can like places, comment on places, post new spots, and include their favorite spots around Durham. To implement this, we plan to use the Yelp Dataset, which provides information about Durham businesses, MapKit, and location information from the iPhone. 

Architecture
- Database
    - Store information about locations
    - User like count
    - Comments
    - Images
    - Category
        - Restaurants, Study Spaces, Coffee Shops, Bars, Activities

- Inputted popular places
    - We will pre-populate database with popular places around Duke that we will gather from our peers  

- Store user profiles
    - User Profiles
        - Logging in and out
        - Signing up
        - Duke account vs. guest account
- Yelp API
    - Provide general information about businesses in Durham
- General Map
    - Map of Durham area with a search bar
- Detail Pages
    - Details about each location, including pictures, images, likes, comments from Duke students
- Upload Page
    - If a user is a student, then they can upload places that they like for different categories

Desired parts of the app
- User data extraction and assimilation 
- Data of places from yelp
- Map and location with pictures
- UI design 

