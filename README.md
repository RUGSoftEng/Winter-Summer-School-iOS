# Winter-Summer-School-iOS

## Description

The Winter-Summer-School-iOS repository contains the source code for the University of Groningen's Summer School iOS App. This App serves users important data pertaining to their summer school's activities. More specifically, it provides users with a means to view general information about their program, receive important announcements, and keep up to date with planned activities using the built-in schedule. It additionally allows them to familiarize themselves with the program's lecturers, and discuss with other members using the provided forum.

## Table of Contents

1. Installation
2. Usage
3. Contributing
4. Credits
5. License

## Installation

Installation of the Winter-Summer-Schools-iOS App requires a few extra steps if you're building the project on Xcode 8.2.1 (as I am). Namely, I have made the following changes to the repository: 
* Removed: `FileProvider.framework` from the root directory. 
* Removed: `IOSurface.framework` from the root directory.
* Removed: `GoogleService-Info.plist` required for FireBase.
The removal of the frameworks was purely due to their inclusion being a workaround to not working on Xcode 9.x. If you're running a later version of Xcode, you should have access to these frameworks by default. Furthermore, the exclusion of files such as the GoogleService property list are for security reasons. If you're planning to use FireBase with this application, you're going to have to obtain a new one for yourself.


## Usage

This application mostly sticks to well known Apple standards for UI design, and so usage should be completely intuitive to anyone familiar with devices running iOS.

For more guides, see the Github Wiki. 

## Contributing

There are no specific contribution preferences at this time.

## Credits

This project is authored by [Charles Randolph](https://github.com/Micrified) on behalf of [Rugged Software](https://github.com/RUGSoftEng).

## License

The project license will be added shortly. 
