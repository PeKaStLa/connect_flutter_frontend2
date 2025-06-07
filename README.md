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
- later change zoom when tapped area is too big or too small the make sure it gets shown in optimal size. Maybe use this formular: y ≈ 6170 * x^6.77 / 100

    x = 12.75: y ≈ 6170 * (12.75)^6.77 / 100 ≈ 2303.49 (actual value: 2300)
    x = 11: y ≈ 6170 * (11)^6.77 / 100 ≈ 7613.89 (actual value: 7600)
    x = 14: y ≈ 6170 * (14)^6.77 / 100 ≈ 810.13 (actual value: 800)
    x = 13.2: y ≈ 6170 * (13.2)^6.77 / 100 ≈ 1603.45 (actual value: 1600)
    x = 11.9: y ≈ 6170 * (11.9)^6.77 / 100 ≈ 4004.19 (actual value: 4000)

This formula seems to fit the data much better. Keep in mind that this is still an approximation, and there might be other formulas that fit the data even better.




