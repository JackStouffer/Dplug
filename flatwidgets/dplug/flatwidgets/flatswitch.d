/**
Film-strip on/off switch.

Copyright: Ethan Reker 2017.
Copyright: Guillaume Piolat 2018.
License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/

module dplug.flatwidgets.flatswitch;

import std.math;
import dplug.core.math;
import dplug.graphics.drawex;
import dplug.gui.element;
import dplug.client.params;

class UIImageSwitch : UIElement, IParameterListener
{
public:
nothrow:
@nogc:

    enum Orientation
    {
        vertical,
        horizontal
    }

    Orientation orientation = Orientation.vertical;

    this(UIContext context, BoolParameter param, OwnedImage!RGBA onImage, OwnedImage!RGBA offImage)
    {
        super(context, flagRaw);
        _param = param;
        _param.addListener(this);

        _onImage = onImage;
        _offImage = offImage;
        assert(_onImage.h == _offImage.h);
        assert(_onImage.w == _offImage.w);
        _width = _onImage.w;
        _height = _onImage.h;

    }

    ~this()
    {
        _param.removeListener(this);
    }

    bool getState()
    {
      return unsafeObjectCast!BoolParameter(_param).valueAtomic();
    }

    override void onDrawRaw(ImageRef!RGBA rawMap, box2i[] dirtyRects)
    {
          auto _currentImage = getState() ? _onImage : _offImage;
          foreach(dirtyRect; dirtyRects)
          {
              auto croppedRawIn = _currentImage.crop(dirtyRect);
              auto croppedRawOut = rawMap.crop(dirtyRect);

              int w = dirtyRect.width;
              int h = dirtyRect.height;

              for(int j = 0; j < h; ++j)
              {
                  RGBA[] input = croppedRawIn.scanline(j);
                  RGBA[] output = croppedRawOut.scanline(j);

                  for(int i = 0; i < w; ++i)
                  {
                      ubyte alpha = input[i].a;

                      RGBA color = RGBA.op!q{.blend(a, b, c)} (input[i], output[i], alpha);
                      output[i] = color;
                  }
              }
          }
    }

    override bool onMouseClick(int x, int y, int button, bool isDoubleClick, MouseState mstate)
    {
        // double-click => set to default
        _param.beginParamEdit();
        _param.setFromGUI(!_param.value());
        _param.endParamEdit();
        return true;
    }

    override void onMouseEnter()
    {
        setDirtyWhole();
    }

    override void onMouseMove(int x, int y, int dx, int dy, MouseState mstate)
    {        
    }

    override void onMouseExit()
    {
        setDirtyWhole();
    }

    override void onBeginDrag()
    {
    }

    override void onStopDrag()
    {
    }
    
    override void onMouseDrag(int x, int y, int dx, int dy, MouseState mstate)
    {        
    }

    override void onParameterChanged(Parameter sender) nothrow @nogc
    {
        setDirtyWhole();
    }

    override void onBeginParameterEdit(Parameter sender)
    {
    }

    override void onEndParameterEdit(Parameter sender)
    {
    }

protected:

    BoolParameter _param;
    bool _state;
    OwnedImage!RGBA _onImage;
    OwnedImage!RGBA _offImage;
    int _width;
    int _height;
}
