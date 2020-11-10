**Duke Life Overview**
We are planning to make a mobile application to guide students and visitors around Durham, in order to give them a better sense of life at Duke. Duke Life aims to help people not only assimilate to living at Duke, but also grow out of their bubble and take advantage of all the places Durham has to offer during their 4 years at Duke. Our mobile application will include an interactive map of spots on campus and in the greater Durham area, which was implemented via MapKit. Users can browse through four categories of places: including food, coffee, bars, and fun. Places are sorted by popularity, which is determined by students at Duke.

As a student, who creates an account with a valid Duke email, you can like, leave comments, and post pictures for certain places, as well as request new spots in the Durham area to be added to the app. Students can view an archive of places they like, as well as places that other students like. As a guest, you have access to the map and list of places for each category. However, guests can’t like, comment, add photos, or request new places, in order for the places and opinions in Duke Life to reflect current students’ preferences– and thus, Duke Life. Guests can also save places to their profile to keep an archive of places that they are interested in or would like to visit. For each place in Duke Life, students and guests can view the address, phone number, website, pictures posted by students, number of student likes, and comments left by students. 

To implement Duke Life, we used the Yelp API to preload over 100 food, coffee, bars, and fun places in the Durham area into our application. We continue to use the Yelp API to allow students to search for places in Durham to add to the application. Once requesting a place, we will review it before adding it to the application, in order to avoid inappropriate or spam additions.

**Components**
- Database (Firebase)
    - Places information, including name, type (category), website URL, address, phone number, latitude, longitude, like count, display image
    - Likes for students, including place and user
    - Comments, including place, user, comment text, time
    - Guest accounts, including name, email
    - Student accounts, including email and netId
    - Saved places for guests, including place and user
    - Images for places, including imamgeUrl (uploaded by students and saved in Firebase storage) and place
    - Requested places, including all information listed above for places (will be transfered to places collection after approval)

Group Members: Abby Mapes, Isabella Geraci, Ji Yun Hyo, Moses Fuego
