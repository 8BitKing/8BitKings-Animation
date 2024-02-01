# 8BitKings Animation
Simple animation system for gamemaker. Work with sprites as if in an object but without the object.

In the repo you can find the scr_animation.gml which is the single script that you want, there is also the .yymps file which is a local package you can import into gamemaker.
Furthermore there is an Animation Examples which contains a Game Maker Project that shows you what this can do and also explains how it works, I recommend taking a look at it.

The Idea is simple, I implement a constructor function that represents a sprite animation. It as a sprite_index, image_index, image_speed etc. just as you would expect if you were working with the sprite of an object. Then there is the update function for the step event that increases the image_index according to the image_speed and image_speed_type you define in the sprite and the draw function that draws the animation whereever you want with whatever alpha and scale.
Imagine you want your character to hold a cool flaming animated sword. Usually there is no other comfy way to implement the animation than to make the sword an object that follows the player so it plays the animaiton but I think that is too much, in some cases you just want to draw an animation.
While I was at it I added some extra features that I would not want to give up ever again:
endactions => decide how the animation behaves when it reaches the end. Make it loop or hold the last frame or bounce back.
callbacks => map a function to a index of the animaiton that gets called when the animaiton reaches that point.
stacks => an animation can have children! they inherit the parent position and scale and so on there is lots of fun stuff you can do with that
sequences => play spriteanimaitons in sequence with a few lines of code.

To get a better understanding please check out the animation provided below and the examlpe project provided in the repo, that explains what excatly is going on.

![](https://github.com/8BitKing/8BitKings-Animation/blob/main/examples.gif)
