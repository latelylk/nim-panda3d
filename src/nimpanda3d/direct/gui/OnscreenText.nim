{.experimental: "codeReordering".} # It's just sexier to write the functions after the constructor

import ../../panda3d/core
import std/options
import ../../direct/showbase # used for parenting 

type
    Style* = enum
      ## These are the styles of text we might commonly see.  They set the
      ## overall appearance of the text according to one of a number of
      ## pre-canned styles.  You can further customize the appearance of the
      ## text by specifying individual parameters as well.
      plain = 1,
      screenTitle = 2,
      screenPrompt = 3,
      nameConfirm = 4
      blackOnWhite = 5

    OnscreenText* = object of NodePath
        text: string
        style: Style
        pos: LVecBase2
        roll: float # not sure what this is but we make it float
        scale: Option[LVecBase2] # This may either be a single float (and it will usually be a small number like 0.07) or it may be a 2-tuple of floats, specifying a different x, y scale.
        # Bc nim typing I make this happen i make setter an overload that does both
        fg: Option[LVecBase4]
        bg: Option[LVecBase4]
        shadow: Option[LVecBase4]
        shadowOffset: LVecBase2
        frame: Option[LVecBase4]
        align: int
        wordwrap: Option[float]
        drawOrder: Option[int]
        decal: bool
        font: Option[TextFont]
        parent: Option[NodePath]
        sort: int
        mayChange: bool
        direction: Option[int]
        textNode: Option[TextNode]
        isClean: bool
        #[
        Make a text node from string, put it into the 2d sg and set it
        up with all the indicated parameters.
        Parameters:
          text: the actual text to display.  This may be omitted and
              specified later via setText() if you don't have it
              available, but it is better to specify it up front.
          style: one of the pre-canned style parameters defined at the
              head of this file.  This sets up the default values for
              many of the remaining parameters if they are
              unspecified; however, a parameter may still be specified
              to explicitly set it, overriding the pre-canned style.
          pos: the x, y position of the text on the screen.
          scale: the size of the text.  This may either be a single
              float (and it will usually be a small number like 0.07)
              or it may be a 2-tuple of floats, specifying a different
              x, y scale.
          fg: the (r, g, b, a) foreground color of the text.  This is
              normally a 4-tuple of floats or ints.
          bg: the (r, g, b, a) background color of the text.  If the
              fourth value, a, is nonzero, a card is created to place
              behind the text and set to the given color.
          shadow: the (r, g, b, a) color of the shadow behind the text.
              If the fourth value, a, is nonzero, a little drop shadow
              is created and placed behind the text.
          frame: the (r, g, b, a) color of the frame drawn around the
              text.  If the fourth value, a, is nonzero, a frame is
              created around the text.
          align: one of TextNode.ALeft, TextNode.ARight, or TextNode.ACenter.
          wordwrap: either the width to wordwrap the text at, or None
              to specify no automatic word wrapping.
          drawOrder: the drawing order of this text with respect to
              all other things in the 'fixed' bin within render2d.
              The text will actually use drawOrder through drawOrder +
              2.
          decal: if this is True, the text is decalled onto its
              background card.  Useful when the text will be parented
              into the 3-D scene graph.
          font: the font to use for the text.
          parent: the NodePath to parent the text to initially.
          mayChange: pass true if the text or its properties may need
              to be changed at runtime, false if it is static once
              created (which leads to better memory optimization).
          direction: this can be set to 'ltr' or 'rtl' to override the
              direction of the text.
        ]#

proc newOnscreenText*(text = "",
                      style = plain,
                      pos = LVecBase2(x: 0f, y: 0f),
                      roll = 0f,
                      scale = none(LVecBase2),
                      fg = none(LVecBase4),
                      bg = none(LVecBase4),
                      shadow = none(LVecBase4),
                      shadowOffset =  LVecBase2(x: 0.04, y: 0.04),
                      frame = none(LVecBase4),
                      align = ord(TextProperties.A_center), # this is an int for compatibility
                      wordwrap = none(float),
                      drawOrder = none(int),
                      decal = false,
                      font = none(TextFont),
                      parent = none(NodePath),
                      sort = 0,
                      mayChange = true,
                      direction = none(int),
                      textNode = none(TextNode),
                      isClean = true
                      ): OnscreenText =
  result = OnscreenText(text: text,
                            style: style,
                            pos: pos,
                            roll: roll,
                            scale: scale,
                            fg: fg,
                            bg: bg,
                            shadow: shadow,
                            shadowOffset: shadowOffset,
                            frame: frame,
                            align: align, # int -> enum
                            wordwrap: wordwrap,
                            drawOrder: drawOrder,
                            decal: decal,
                            font: font,
                            parent: parent,
                            sort: sort,
                            mayChange: mayChange,
                            direction: direction,
                            textNode: textNode,
                            isClean: isClean)
  if result.parent.isNone:
    result.parent = some(aspect2d)
  
  # make a text node
  var textNode = some(newTextNode(""))
  result.textNode = textNode

  # var np = initNodePath()
  #[
            # We ARE a node path.  Initially, we're an empty node path.
        NodePath.__init__(self)

  ]#

  # Choose the default parameters according to the selected
  # style.
  case result.style:
    of plain:
      result.scale = (if scale.isSome:
                        scale
                      else:
                        option[LVecBase2]((0.07, 0.07)))
      result.fg = (if fg.isSome:
                      fg
                    else:
                      option[LVecBase4]((0f, 0f, 0f, 1f)))
      result.bg = (if bg.isSome:
                      bg
                    else:
                      option[LVecBase4]((0f, 0f, 0f, 0f)))
      result.shadow = (if shadow.isSome:
                        shadow
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 0f)))
      result.frame = (if frame.isSome:
                        frame
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 0f)))
    of screenTitle:
      result.scale = (if scale.isSome:
                        scale
                      else:
                        option[LVecBase2]((0.15, 0.15)))
      result.fg = (if fg.isSome:
                      fg
                    else:
                      option[LVecBase4]((1f, 0.2, 0.2, 1f)))
      result.bg = (if bg.isSome:
                      bg
                    else:
                      option[LVecBase4]((0f, 0f, 0f, 0f)))
      result.shadow = (if shadow.isSome:
                        shadow
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 1f)))
      result.frame = (if frame.isSome:
                        frame
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 0f)))
    of screenPrompt:
      result.scale = (if scale.isSome:
                        scale
                      else:
                        option[LVecBase2]((0.1, 0.1)))
      result.fg = (if fg.isSome:
                      fg
                    else:
                      option[LVecBase4]((1f, 1f, 0f, 1f)))
      result.bg = (if bg.isSome:
                      bg
                    else:
                      option[LVecBase4]((0f, 0f, 0f, 0f)))
      result.shadow = (if shadow.isSome:
                        shadow
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 1f)))
      result.frame = (if frame.isSome:
                        frame
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 0f)))
    of nameConfirm:
      result.scale = (if scale.isSome:
                        scale
                      else:
                        option[LVecBase2]((0.1, 0.1)))
      result.fg = (if fg.isSome:
                      fg
                    else:
                      option[LVecBase4]((0f, 1f, 0f, 1f)))
      result.bg = (if bg.isSome:
                      bg
                    else:
                      option[LVecBase4]((0f, 0f, 0f, 0f)))
      result.shadow = (if shadow.isSome:
                        shadow
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 0f)))
      result.frame = (if frame.isSome:
                        frame
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 0f)))
    of blackOnWhite:
      result.scale = (if scale.isSome:
                        scale
                      else:
                        option[LVecBase2]((0.1, 0.1)))
      result.fg = (if fg.isSome:
                      fg
                    else:
                      option[LVecBase4]((0f, 0f, 0f, 1f)))
      result.bg = (if bg.isSome:
                      bg
                    else:
                      option[LVecBase4]((1f, 1f, 1f, 1f)))
      result.shadow = (if shadow.isSome:
                        shadow
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 0f)))
      result.frame = (if frame.isSome:
                        frame
                      else:
                        option[LVecBase4]((0f, 0f, 0f, 0f)))
  #[
          else:
            raise ValueError

        if not isinstance(scale, tuple):
            # If the scale is already a tuple, it's a 2-d (x, y) scale.
            # Otherwise, it's a uniform scale--make it a tuple.
            scale = (scale, scale)

        # Save some of the parameters for posterity.
        self.__scale = scale
        self.__pos = pos
        self.__roll = roll
        self.__wordwrap = wordwrap
  ]#

  if result.decal: # bool tho??
    get(textNode).setCardDecal(true)

  if result.font.isNone:
      result.font = some(TextProperties.getDefaultFont())

  get(textNode).setFont(get(result.font))
  get(textNode).setTextColor(get(result.fg))
  get(textNode).setAlign(TextProperties.Alignment(result.align)) #! TextProperties.Alignment() converts an int to an alignment for p3d compat

  if result.wordwrap.isSome:
    get(textNode).setWordwrap(get(result.wordwrap))

  if get(result.bg).w != 0f:
    # If we have a background color, create a card.
    get(textNode).setCardColor(get(result.bg))
    get(textNode).setCardAsMargin(0.1, 0.1, 0.1, 0.1)

  if get(result.shadow).w != 0f:
    # If we have a shadow color, create a shadow.
    get(textNode).setShadowColor(get(result.shadow))
    get(textNode).setShadow(result.shadowOffset)

  if get(result.frame).w != 0:
    # If we have a frame color, create a frame.
    get(textNode).setFrameColor(get(result.frame))
    get(textNode).setFrameAsMargin(0.1, 0.1, 0.1, 0.1)

  if not result.direction.isNone:
    get(textNode).setDirection(TextProperties.Direction(get(result.direction)))#! TextProperties.Direction() converts an int to an alignment for p3d compat

  # Create a transform for the text for our scale and position.
  # We'd rather do it here, on the text itself, rather than on
  # our NodePath, so we have one fewer transforms in the scene
  # graph.
  result.updateTransformMat()

  if not drawOrder.isNone:
    get(textNode).setBin("fixed")
    discard get(textNode).setDrawOrder(get(result.drawOrder))

  result.setText(result.text)
  if result.text == "":
      # If we don't have any text, assume we'll be changing it later.
      result.mayChange = true

  # Ok, now update the node.
  if not result.mayChange:
    # If we aren't going to change the text later, we can
    # throw away the TextNode.
    textNode = some((TextNode)get(textNode).generate()) # This is some trickery bc issue going between PandaNode and TextNode with scales ??

  result.isClean = false

  # Set ourselves up as the NodePath that points to this node.
  discard attachNewNode(get(result.parent), get(textNode), result.sort)

proc cleanup(result: var OnscreenText) =
  result.textNode = none(TextNode)
  if result.isClean:
      result.isClean = true
      result.removeNode()

#[ Are these useful ??
  def destroy(self):
    self.cleanup()

  def freeze(self):
    pass

  def thaw(self):
    pass
]#

# Allow changing of several of the parameters after the text has
# been created.  These should be used with caution; it is better
# to set all the parameters up front.  These functions are
# primarily intended for interactive placement of the initial
# text, and for those rare occasions when you actually want to
# change a text's property after it has been created.

func setDecal(self: OnscreenText, decal: bool) =
  get(self.textNode).setCardDecal(decal)

func getDecal(self: OnscreenText): bool =
  result = get(self.textNode).getCardDecal()

# var decal = property(getDecal, setDecal)

func setFont(self: OnscreenText, font: TextFont) =
  get(self.textNode).setFont(font)

func getFont(self: OnscreenText): TextFont =
  result = get(self.textNode).getFont()

# var font = property(getFont, setFont)

func clearText(self: OnscreenText) =
  get(self.textNode).clearText()

func setText(self: OnscreenText, text: string) =
  get(self.textNode).setText(text) #setWtext ?? # note: Reason: cannot convert from 'std::string' to 'const std::wstring'

func appendText(self: OnscreenText, text: string) =
  get(self.textNode).appendWtext(text) # Not sure if this will work bc setWText didn't

func getText(self: OnscreenText): string =
  return get(self.textNode).getWtext() # and this WText too ??

# var text = property(getText, setText)

proc setTextX(self: var OnscreenText, x: float32) =
  #[
  .. versionadded:: 1.10.8
  ]#
  self.setTextPos(x, some(self.pos.y))

proc setTextY(self: var OnscreenText, y: float32) =
  #[
  .. versionadded:: 1.10.8
  ]#
  self.setTextPos(self.pos.x, some(y))

proc setTextPos(self: var OnscreenText, x: float32, y: Option[float32] = none(float32)) = 
  #[
  Position the onscreen text in 2d screen space
  .. versionadded:: 1.10.8
  ]#
  if y.isNone:
      self.pos = (x: x, y: x)
  else:
      self.pos = (x: x, y: get(y))
  self.updateTransformMat()

func getTextPos(self: OnscreenText): LVecBase2 =
  #[
  .. versionadded:: 1.10.8
  ]#
  return self.pos

# var text_pos = property(getTextPos, setTextPos)

func setTextR(self: var OnscreenText, r: float) =
  #[setTextR(self, float)
  Rotates the text around the screen's normal.
  .. versionadded:: 1.10.8
  ]#
  self.roll = -r
  self.updateTransformMat()

func getTextR(self: OnscreenText): float =
  return -self.roll

# var text_r = property(getTextR, setTextR)

func setTextScale(self: var OnscreenText, sx: float32, sy: Option[float32] = none(float32)) =
  #[setTextScale(self, float, float)
  Scale the text in 2d space.  You may specify either a single
  uniform scale, or two scales.
  .. versionadded:: 1.10.8
  ]#

  if sy.isNone:
    self.scale = option[LVecBase2]((sx, sx))
  else:
      self.scale = option[LVecBase2]((sx, get(sy)))
  self.updateTransformMat()

func updateTransformMat(self: OnscreenText) =
  var mat: LMatrix4 = (
      Mat4.scaleMat(Vec3.rfu(get(self.scale)[0], 1, get(self.scale)[1])) *
      Mat4.rotateMat(self.roll, Vec3.back()) *
      Mat4.translateMat(Point3.rfu(self.pos[0], 0, self.pos[1]))
      )
  get(self.textNode).setTransform(mat)


