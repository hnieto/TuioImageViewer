import java.io.Serializable;

static class PictureState implements Serializable {
  
  // Picture Attributes
  final int id;
  final PVector location;
  final float[] dim;
  final float zoom;
  final float theta;
  final String imgDescription;
  final boolean showPicture;
  final boolean showText;
  final String borderColor;
  final float leaderWidth;
  
  PictureState(final int _id, final PVector _location, final float[] _dim, final float _zoom, final float _theta, final String _imgDescription, final boolean _showPicture, final String _borderColor, final float _leaderWidth) {
    id = _id;
    location = _location;
    dim = _dim;
    zoom = _zoom;
    theta = _theta;
    imgDescription = _imgDescription;
    showPicture = _showPicture;
    showText = !showPicture;
    borderColor = _borderColor;
    leaderWidth = _leaderWidth;
  }  
}
