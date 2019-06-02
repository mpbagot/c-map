class Transformation
  var position: Array[U32] ref
  var rotation: Array[U16] ref
  var scale: Array[F64] ref
  // var filters: Array[Filter]

  new create() =>
    position = [0; 0; 0]
    rotation = [0; 0; 0]
    scale = [1; 1; 1]

  fun ref set_pos(pos: Array[U32] ref) ? =>
    if pos.size() == 3 then
      position = pos
    elseif pos.size() == 2 then
      position.update(0, pos.apply(0)?)?
      position.update(1, pos.apply(1)?)?
    else
      error
    end

  fun ref set_rot(rot: Array[U16]) ? =>
    if rot.size() == 3 then
      rotation = rot
    else
      error
    end

  fun ref set_scale(sc: Array[F64]) ? =>
    if sc.size() == 3 then
      scale = sc
    else
      error
    end

  // fun ref add_filter(filter: Filter) =>
  //   filters.push(filter)

class Scene
  """
  A class to hold data about a scene.
  """

  var layers: Array[Layer]

  new create() =>
    """
    Create a new scene with a single empty layer.
    """
    layers = [Layer.create()]

  fun ref add_layer(layer: Layer = Layer.create()) =>
    """
    Add a new layer to the scene.
    If `layer` is not given, an empty layer is created.
    """
    layers.push(layer)

class Layer
  """
  A class to represent a layer
  """

  var children: Array[ImageObject]

  var transform: Transformation = Transformation.create()

  new create() =>
    """
    Create an empty layer, containing no visible objects.
    """
    children = []

class ImageObject
  """
  The ImageObject holds information about an image.
  Additional child images can be attached to the ImageObject to allow for heirarchical
  transformations and layer structuring.
  """

  var image: (Image | None)
  var children: Array[ImageObject]

  var transform: Transformation = Transformation.create()

  new create(img: (Image | None), pos: Array[U32], rot: (Array[U16] | None)) =>
    """
    Create a new ImageObject.
    If `img` is None, the object is an empty parent object for child images.
    """
    children = []
    try
      transform.set_pos(pos)?
    end
    try
      transform.set_rot(rot as Array[U16])?
    end
    image = img

  fun ref rotate() =>
    """
    Set the rotation of the image object
    """
    U8(0)

  fun ref translate(new_pos: Array[U32]) =>
    """
    Translate the image object (and all children) to a given position
    """
    try
      transform.set_pos(new_pos)?
    end

  fun ref scale(sc: (Array[F64] | F64)) =>
    """
    Scale an image object on all axes, or independently.
    """
    try
      match sc
      | let x: Array[F64] => transform.set_scale(x)?
      | let x: F64 => transform.set_scale([x; x; x])?
      end
    end
