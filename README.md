# connect_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Plan:
- Web-/App where everyone has an area in every location and can chat without making a group or exchanging number or usernames...
- user can filter their area for male/female, age, verified
- users can decide if other users can see/find them
- users can see other users in their specific area and also other areas that are available at their location....
- users can subscribe to areas to still being able to chat even when they move away from them...
- users can connect/follow/friendship with other users and chat privately...
- later user can connect via near-bluetooth
- evtl. function that a few users on one spot automatically create/connect to one area? 
- or every user has an own area and when users come close together they connect somehow into one area??? for example a concert or comic con there would be no need to create one are for those locations...(but locations still make sense for hostels... or the concert location.)
- maybe user can subscribe to a location before being there?? concert??
- areas have different categories..
- the areas need to know which users are in them...
- go backend using R-tree or better R*-tree cause fast
- ...
- frontend Apps und Web in flutter cause 3-in-1
- backend with go and supabase (inclusive authentication and postgresDB)
- for infra use "just" command runner and free OKD (OpenShift cluster inclusive cicd and dev tools)
- ...
- BACKEND:
- https://connect.pockethost.io/_/#/collections?collection=_pb_users_auth_&filter=&sort=-%40rowid
- ...
- use JavaScript R-Tree and k-nearest neighbours
- https://github.com/mourner/rbush
- https://github.com/mourner/rbush-knn
- ...
- TODO:
- calculate area perimeter and PIXEL based on the Latitude! If not the same circles at Antarctica and Äquator would be same size even though they should be really different sized.
- improve chat cache. Evtl. ist der komplett nutzlos, wenn ich die maximale area-cache Länge ändere auf von 5 auf 2 ändert sich überhaupt gar nichts.... Evtl. reicht es aus die Hive-Boxes nicht zu schließen, dass der chatcontroller den cache/memory selbst managed?
- Wenn das Chat overlay geöffnet und generiert wird kommt oft der Fehler: EBLASTBufferQueue(21326): SurfaceView[com.example.connect_flutter/com.example.connect_flutter. MainActivity ] # 1 acquireNextBufferLocked: Can't acquire next buffer. Already acquired max frames 4 max:2 + 2
- => chatgpt says: Don’t forget: Hive boxes should not be reopened after being closed without calling Hive.openBox again. So cache disposal should only happen when you’re truly done with the data (e.g., leaving chat or app exit).
- ...
- ....
- ....
- ....
- next change zoom when tapped area is too big or too small the make sure it gets shown in optimal size. ALSO: find out best zoom? When only area is visible or also areas around this area? Devonport Area is a bit close to the upper Detail-Field. Maybe need a better formular for the future???
- ...
- device location gps or choose point on map / city from list...
- ....
- how to find out if user is in area?????????
- Initial zoom to the current area and update the backend user info!
- ...
- wie machen mit Anmeldung? 
- Chatten nur mit real GPS location? oder auch mit frei gewählter Location?
- Chatten ohne Anmeldung? 
- Chatten wenn in keine Area?
- Chatten nur in der aktuellen Area oder auch drum herum?
- wann möglich andere Areas zu subscriben???
- Wie weiter Location-Distance-Filter?
- ...
- Evtl: wenn unangemeldet kann der User alle Areas sehen und seine Location und die Chats öffnen, aber er darf nicht selbst Messages senden. 
- Senden Button gibt dann die Nachricht DU bist nicht angemeldet. 
- Und die Buttons für Goofle/Apple/Facebook/E-MailPassword erscheinen.
- => TOP, gute Idee.
- ....
- ...test
- chat send message Button ausgrauen wenn guest-user nicht eingeloggt?
- ...
- ...
- ...
- Errors when opening settings overlay:

Reloaded 2 of 1484 libraries in 626ms (compile: 
34 ms, reload: 283 ms, reassemble: 158 ms).     
W/WindowOnBackDispatcher(32525): OnBackInvokedCallback is not enabled for the application.      
W/WindowOnBackDispatcher(32525): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
E/BLASTBufferQueue(32525): [SurfaceView[com.example.connect_flutter/com.example.connect_flutter.MainActivity]#1](f:1,a:4) acquireNextBufferLocked: Can't acquire next buffer. Already acquired max frames 4 max:2 + 2
E/BLASTBufferQueue(32525): [SurfaceView[com.example.connect_flutter/com.example.connect_flutter.MainActivity]#1](f:1,a:4) acquireNextBufferLocked: Can't acquire next buffer. Already acquired max frames 4 max:2 + 2
E/BLASTBufferQueue(32525): [SurfaceView[com.example.connect_flutter/com.example.connect_flutter.MainActivity]#1](f:1,a:4) acquireNextBufferLocked: Can't acquire next buffer. Already acquired max frames 4 max:2 + 2
E/BLASTBufferQueue(32525): [SurfaceView[com.example.connect_flutter/com.example.connect_flutter.MainActivity]#1](f:1,a:4) acquireNextBufferLocked: Can't acquire next buffer. Already acquired max frames 4 max:2 + 2
E/BLASTBufferQueue(32525): [SurfaceView[com.example.connect_flutter/com.example.connect_flutter.MainActivity]#1](f:1,a:4) acquireNextBufferLocked: Can't acquire next buffer. Already acquired max frames 4 max:2 + 2

- ...
- ...
- ...
- noch die genauen errors ausscjreiben statt nur error message


possible error at registration:
- invalid mail, 
- mail already taken
- password dont match, 
- ???username already taken=>is not an error currently...???
- ....

possible error at login:
- mail cannot be blank
- password cannot be blank
- => for rest: failed to authenticate
- ....
- ...
- Marker calculation verbessern!
- evtl. nur alle 100-300ms berechnen...
- oder standardwerte für bestimmte Zooms speichern
- ...
- evtl load and/or calculate only visible markers in viewport...
- =>
- 1. Determine the visible region of your map (the current viewport or bounds).
- 2. Filter your areas to include only those whose coordinates (center or bounding box) are within the visible region.
- 3. Call calculateMarkerSizeForArea only for those filtered areas.
- ...
- ....
- Avoid unnecessary setState calls: Ensure that setState is only called when absolutely necessary and that it rebuilds the smallest possible portion of the widget tree.
- ...


