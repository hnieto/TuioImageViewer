import java.io.Serializable;

class CursorState implements Serializable {
  final float x;
  final float y;
  final float w;
  final float h;
  final String cursorColor;  
  
  CursorState(final float _x, final float _y, final float _w, final float _h, final String _cursorColor) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    cursorColor = _cursorColor;
  }  
}


