class Scene

  var layers: Array[Layer]

  new create() =>
    layers = [Layer.create()]

  fun ref add_layer() =>
    layers.push(Layer.create())

class Layer

  var children: Array[ImageObject]

  new create() =>
    children = []

class ImageObject

  var children: Array[ImageObject]
  var position: Array[U32]
  var rotation: Array[U16]
  var image: (Image | None)

  new create(pos: Array[U32], rot: (Array[U16] | None)) =>
    children = []
    position = pos
    rotation = [0; 0]
    try
      rotation = rot as Array[U16]
    end
    image = None

  fun ref rotate() =>
    U8(0)

  fun ref translate(new_pos: Array[U32]) =>
    this.position = new_pos
