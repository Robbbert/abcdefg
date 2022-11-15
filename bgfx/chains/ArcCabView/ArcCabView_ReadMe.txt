ArcCabView BGFX_Chain 2.2b for MAME by Aubrel
(MOD of CRTGeom-Deluxe BGFX Chain by cgwg)


Changelog :
- aperture mask code changed to match the grill and to look like our Reshade's Shader
- support for 2x2 and 1x1 slot mask textures (auto switch)
- native frame display support (with and without curvature)
- screen reflection on frame added
- frame size setting added (so you can change the frame image and resize according to the new one)
- curvature without CRT effect added
- better overscan support and offsets support added (so now you can resize and crop your games correctly :)
- many settings and details improved
- native overlay image support added (from 1.1 the overlay image alpha value is exponential)
- improved brightness and black dots render (1.1)
- halation effect improved to catch the screen dots and to look more realistic (1.1)
- big performance improvement (1.2)
- brightness, contrast, halation, reflection and overlay adjustements (1.2a)
- half-curv & half-frame added for 2 screens games (1.3)
- small typo in reflexion code fixed, curvature effect settings slightly reduced (1.4)
- moire effect reduced, frame reflection contrast improved (1.4a)
- many things rewritten from scratch, many small issues fixed (2.0)
- even more performance improvements (2.0)
- the overall display result should be improved (2.0)
- the previous annoying moire effect issue should be now fully fixed (2.0)
- the mask texture 1x1 is now used by default (2.0)
- many default settings updated and improved (2.0)
- CRT brightness increased (2.0a)
- small cleanups, impovements and adjustements (2.1)
- overlay texture removed and now simulated (2.2)
- frame texture size and code updated (2.2)
- some performance improvements (2.2)
- frame display when changing the chains ingame fixed (2.2a)
- aperture_strength value reduced (2.2a)
- shader textures moved to artwork/bgfx/chains/ArcCabView (2.2b)
...

- BGFX Chains alternative presets :
- "ArcCabView_ResX2" : it doubles the horizontal resolution and adds the alternate pixel effect (to use only with low-res games or with big High-Res screens)
- "ArcCabView_Flat" : it removes the curvature, the corners, the raster-bloom effect and the frame (good to use with multi-screens games)

Info / Support : http://www.emuline.org/topic/2598-arccabview-display-your-arcade-games-just-as-you-want/
