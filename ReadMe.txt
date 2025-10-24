Deliverable 2:
For this deliverable each necessary item was applied to the many CRT screens in the scene, this implementation was done primarily because these are going to be a primary visual element frequented in the game and will be utilized for much of the games visual story telling in future implementation of the routes and endings. By having access to this pool of lighting models already attached to these objects, and preemptively allowing for their toggleability, we will be able to more efficiently use color as our primary visual medium for invoking emotion in the narrative. Each shader is used to showcase and analyse what will be the best approach to shading the objects on the final products and if using special effects (ex. Rim lighting or gradients) might be an interesting approach to them.


Deliverable 3:
This deliverable has implementation of each requirement used throughout the scene for various narrative purposes. The primary global LUT used is a cooling LUT, chosen due to it visually supporting the main intent and theme that the story is intending to portray. The warming LUT and custom LUT are instead applied regionally to give different game feel when the player interacts with and moves through the Level. All of these implementations differ from the class as they are not applied to the main camera, and instead use the unity volume components as these allow for the desired regional implementation.


Deliverable 4:
This deliverable includes 3 shader implementations in particular, a bump shader for walls and furnishing, a toon shader with rim light as it gives a very cell shaded and reflective look to the NPC visors, and a unlit shader with highlighted borders, which is currently not implemented as such, but will be a way to highlight interactable items. By utilizing these shaders we are able to highlight specific areas of the game and guide the player to the answer while not making it obvious. By using the shaders like the bump map shader we can analyse and check in the engine how the UVs of the objects are behaving when affected by light or other game objects.

Game Build does not work, bug with shaders.


https://drive.google.com/drive/folders/1nRVF1Umf9_qHK6j2TVNypx92MEfs9ZWr?usp=sharing