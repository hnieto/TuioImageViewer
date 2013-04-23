import java.io.Serializable;

class PictureState implements Serializable {
  
  // Picture Attributes
  final int id;
  final float x;
  final float y;
  final float z;
  final float w;
  final float h;
  final float scalePercent;
  final float theta;
  final String imgDescription;
  final boolean showPicture;
  final boolean showText;
  final String borderColor;
  
  PictureState(final int _id, final float _x, final float _y, final float _z, final float _w, final float _h, final float _scalePercent, final float _theta, final String _imgDescription, final boolean _showPicture, final boolean _showText, final String _borderColor) {
    id = _id;
    x = _x;
    y = _y;
    z = _z;
    w = _w;
    h = _h;
    scalePercent = _scalePercent;
    theta = _theta;
    imgDescription = _imgDescription;
    showPicture = _showPicture;
    showText = _showText;
    borderColor = _borderColor;
  }  
}
