# Ad Search

## Description

Built an Ad Search app that will allow users to view ads and save them to their local disk for offline viewing.
### Tools used
* UIKit
    * Views, ViewControllers, etc.
* SwiftUI
    * Used to build the UICollectionView Cell ContentConfiguration
* CoreData
    * Used to persist data (saved ads) for offline viewing
* Swift Concurrency
    * Used for Network Requests
* Combine
    * Used to observe and react to changes.

#### Proud of
* It was fun to use FileManager to save images to localDisk (and retrieving them) for offline mode use. 
* I am also happy with the usage of frameworks to isolate unrelated code anda build a clearer, easier to navigate and maintain project structure which is scalable by design.
* I am happy with the inclusion of contentUnavailableConfiguration to provide visual feedabck for empty states. 

#### What I could have done more
* I couldn't handle error messaging a little better. Although I've done decent error handling, having a concrete Error Type would definitely enhancing the error communication to the develop.
* I could improve the image downloader a little better that would help me to have similar performances like libraries like Kingfisher, etc.

#### If I had more time
* I would've added more UI to provide more visual and haptic feedback for user interactions (like saving a ad, etc). I would definitely provide a better UX.

