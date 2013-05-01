import java.io.Serializable;

static class CursorState implements Serializable {
  final float x;
  final float y;
  final float w;
  final float h;
  final String cursorColor;  
  final float leaderWidth;
  
  CursorState(final float _x, final float _y, final float _w, final float _h, final String _cursorColor, final float _leaderWidth) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    cursorColor = _cursorColor;
    leaderWidth = _leaderWidth;
  }  
}


