# Songify

## Demo
### Demo Part 1
<img width="400" alt="Screen Shot 2021-10-29 at 1 47 14 PM" src="http://g.recordit.co/qGWmhNeNWm.gif">

### Demo Part 3
<img width="400" alt="Screen Shot 2021-10-29 at 1 47 14 PM" src="http://g.recordit.co/19DRtz1Aze.gif">

### Demo Part 4
<img width="400" alt="Screen Shot 2021-10-29 at 1 47 14 PM" src="http://g.recordit.co/5DNviufEN3.gif">

## Demo Part 5
<img width="400" alt="Screen Shot 2021-10-29 at 1 47 14 PM" src="http://g.recordit.co/gtAM8THN9u.gif">

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Get albums and songs by identifying an artist from a provided image for the user

### App Evaluation
- **Category:** Entertainment 
- **Mobile:** Completely for mobile use. Utilizes the Spotify API to allow the user to select an artist from a set of images to see the artists entire catalogue.
- **Story:** Allows the convenient use of an artist image to quickly be identified for the user, so that they can just get he/her's associated albums and songs without knowing the name of the artist beforehand.
- **Market:** Any person who want's to get the songs of a particular artist without knowing the name from the world's most popular music-streaming platform, Spotify.
- **Habit:** Any user that wants to know the songs of a particular artist quickly at any time. 
- **Scope:** V1 would simply be to allow a user to get albums and songs from a provided list of artist images. V2 Would allow a user to play songs listed from the artists catalogue.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can scroll through photos.
- [x] User can tap on artist photos to see their music catalogue on the next view.
- [x] User can scroll through album views
- [x] User can tap on album photos to see their included tracks on the next view
- [x] User can scroll through tracks of the selected Album
- [x] User can navigate all the way back to the home screen 

**Optional Nice-to-have Stories**

- [ ] User can sign in through their spotify account
- [ ] Providing the user to the ability to just type in the name of the artist as an alternative to get albums 
- [ ] Being able to play music from the providing artist catalogue.
- [x] User can add in custom artist images
- [x] Have a third party AI Model identify artists based on their image
- [x] Add a progress HUD for network requests
- [x] User can search through found albums
- [x] User can infinitely scroll down through found albums
- [x] User can modify settings to configure the type or order of albums returned 

### 2. Screen Archetypes

* Stream
   * User can scroll through photos
* Stream - Grid view
   * User can scroll through associated Albums
   * User can tap on an album to get Detail view
* Detail - table of tracks
   * displays tracks listed on an album

### 3. Navigation

**Flow Navigation** (Screen to Screen)

* Stream Screen - list of photos
   * => Stream - Album grid view
* Album grid view screen
   * => Detail scren - table of tracks

## Wireframes
<img width="800" alt="Screen Shot 2021-10-29 at 1 47 14 PM" src="https://user-images.githubusercontent.com/66268282/139480042-703c70ec-7b25-4c79-b7c5-2465d64872bb.png">
### [BONUS] Digital Wireframes & Mockups
<img width="714" alt="Screen Shot 2021-10-30 at 10 02 17 PM" src="https://user-images.githubusercontent.com/66268282/139564597-7a9d4088-93fd-4079-94f9-1d4d016b7d51.png">
### [BONUS] Interactive Prototype
<img src="https://user-images.githubusercontent.com/66268282/139564630-9e2905c6-8dfe-42e8-93a9-d86d6aae8c65.gif" width="406" height="733" />

## Schema 

### Models
User
| Property | Type  | Description |
| -------- | -------- | --------     
| userID   | String   | Unique ID for the user
| imageUrls | Array | array of image urls that the user inputs in |

ImageUrl
| Property | Type | Description |
| -------- | -------- | -------- |
| imageUrl    | String     | image url that the user inputs in     |
| author | Pointer to User | link to author who inputted the image | 

### Networking
- Artist Image View Screen
    - (Read/GET) Query all of the user's saved artist images
        - `let query = PFQuery(className="ImageUrl")`
        - `query.whereKey("author", equalTo: currentUser)`
        - `query.findObjectsInBackground { (artists: [PFObject]?, error: Error?) in
   if let error = error {
      print(error.localizedDescription)
   } else if let posts = posts {
      print("Successfully retrieved \(artists.count) posts.")
      // TODO: Do something with artist images...
   }
}`
    - (Create/POST) Create a new artist image for user
        - `let artist = PFObject(className="ArtistImage")`
        - `artist["author"]=currentUser`
        - `artist["imageUrl"] = inputted_url`
        - `currentUser.add(artist, forKey="imageUrls")`
        - `currentUser.saveInBackground { (success, error) in
            if success {
                print("comment saved")
            }
            else {
                print(error!)
            }
        }`
    - (Delete) Delete existing image
        - `let images = currentUser["imageUrls"] as! [PFObject]`
        - `let image = images[idx]`
        - `do {`
            - `currentUser.remove(image, forKey: "imageUrls")`
            - `try image.delete()`
        - `catch {`
            - `print("error deleting image")`
- Album View Screen (from 3rd party API)
    - (Read/GET) Query all of the artist's albums
- Tracklist Detail View Screen (from 3rd party API)
    - (Read/GET) Query all of the artist's albums tracklist

- [OPTIONAL:] Existing API Endpoints
    - Spotify Web API
        - Base URL - https://api.spotify.com/v1
        
|  HTTP Verb |Endpoint | Description |
| -------- | -------- | -------- |
| GET     | /search   | get spotify catalog information regarding artist name, album name, and tracklist     |
| GET     | /artists/{id}/albums   | get spotify catalog information about an artist's albums   |
| GET     | /albums/{id}/tracks   | get spotify catalog information about an artist's albums tracks    |
