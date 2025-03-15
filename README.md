# Godot Planet Walker
Third person 3D arcade planet movement.

## Controls
| key          | action               |
| ------------ | -------------------- |
| WASD         | movement             |
| Click        | capture mouse        |
| Mouse motion | move camera          |
| ESC          | menu / release mouse |
| N            | restart              |

## Video

https://github.com/user-attachments/assets/aa61b0bc-468e-4eb4-9d06-293f3d463cd7

## Gravity
Godot's Area3Ds support point & directional gravity
- Point gravity used for spherical planets
- 4 directional gravity areas surround walkway planets

What to do when Area3Ds overlap?
1. Priority System
2. Combine for a more realistic feel, a la Outer Wilds
3. Use the most recent area entered

GravityDecider does (3) for an arcade feel, a la Super Mario Galaxy

## Improve
1. Erratic camera
2. Custom gravity shapes: cylinder, torus, cone.
3. Arbitrary blob planets that use closest normal vector for gravity?
