# Songify

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

* User can scroll through photos.
* User can tap photos to see an artist music catalogue.

**Optional Nice-to-have Stories**

* Providing the user to the ability to type in an artist name to see an image of the artist as well as their catalogue available on Spotify.
* Being able to play music from the providing artist catalogue.
* User hears a random song by an artist post clicking on the artists image.

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

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
