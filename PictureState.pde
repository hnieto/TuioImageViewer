import java.io.Serializable;

static class PictureState implements Serializable {
  
  // Picture Attributes
  final int id;
  final PVector location;
  final float[] dim;
  final float zoom;
  final String imgDescription;
  final boolean showPicture;
  final int fontSize;
  final String borderColor;
  final float leaderWidth;
  
  PictureState(final int _id, final PVector _location, final float[] _dim, final float _zoom, final String _imgDescription, final boolean _showPicture, final int _fontSize, final String _borderColor, final float _leaderWidth) {
    id = _id;
    location = _location;
    dim = _dim;
    zoom = _zoom;
    imgDescription = _imgDescription;
    showPicture = _showPicture;
    fontSize = _fontSize;
    borderColor = _borderColor;
    leaderWidth = _leaderWidth;
  }  
}
