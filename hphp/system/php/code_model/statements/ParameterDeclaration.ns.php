<?php
// Copyright 2004-present Facebook. All Rights Reserved.
// This file is @generated by
// fbcode/hphp/facebook/tools/code_model/Generate.sh

namespace HH\CodeModel {

/**
 *  [ << attributes >> ]
 *  [modifiers] [typeAnnotation] [&] name [= expression]
 */
class ParameterDeclaration /*implements IParameterDeclaration*/ {
  use NamedNode;
  use Node;

  private /*?Vector<IAttribute>*/ $attributes;
  private /*?Vector<IModifier>*/ $modifiers;
  private /*?ITypeExpression*/ $typeAnnotation;
  private /*?bool*/ $isPassedByReference;
  private /*?IExpression*/ $expression;

  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function getAttributes() /*: Vector<IAttribute>*/ {
    if ($this->attributes === null) {
      $this->attributes = Vector {};
    }
    return $this->attributes;
  }
  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function setAttributes(/*Vector<IAttribute>*/ $value)
     /*: this*/ {
    $this->attributes = $value;
    return $this;
  }

  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function getModifiers() /*: Vector<IModifier>*/ {
    if ($this->modifiers === null) {
      $this->modifiers = Vector {};
    }
    return $this->modifiers;
  }
  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function setModifiers(/*Vector<IModifier>*/ $value)
     /*: this*/ {
    $this->modifiers = $value;
    return $this;
  }

  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function getTypeAnnotation() /*: ?ITypeExpression*/ {
    return $this->typeAnnotation;
  }
  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function setTypeAnnotation(/*?ITypeExpression*/ $value) /*: this*/ {
    $this->typeAnnotation = $value;
    return $this;
  }

  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function getIsPassedByReference() /*: bool*/ {
    if ($this->isPassedByReference === null) {
      return false;
    }
    return $this->isPassedByReference;
  }
  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function setIsPassedByReference(/*bool*/ $value) /*: this*/ {
    $this->isPassedByReference = $value;
    return $this;
  }

  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function getExpression() /*: ?IExpression*/ {
    return $this->expression;
  }
  /**
   *  [ << attributes >> ]
   *  [modifiers] [typeAnnotation] [&] name [= expression]
   */
  public function setExpression(/*?IExpression*/ $value) /*: this*/ {
    $this->expression = $value;
    return $this;
  }

  /**
   * Returns $visitor->visitParameterDeclaration($this) if
   * such a method exists on $visitor.
   * Otherwise returns $visitor->visitStatement($this) if
   * such a method exists on $visitor.
   * Otherwise returns $visitor->visitNode($this) if
   */
  public function accept(/*mixed*/ $visitor) /*: mixed*/ {
    if (method_exists($visitor, "visitParameterDeclaration")) {
      // UNSAFE
      return $visitor->visitParameterDeclaration($this);
    } else if (method_exists($visitor, "visitStatement")) {
      // UNSAFE
      return $visitor->visitStatement($this);
    } else {
      return $visitor->visitNode($this);
    }
  }

  /**
   * Yields a list of nodes that are children of this node.
   * A node has exactly one parent, so doing a depth
   * first traversal of a node graph using getChildren will
   * traverse a spanning tree.
   */
  public function getChildren() /*: Continuation<INode>*/ {
    if ($this->attributes !== null) {
      foreach ($this->attributes as $elem) {
        yield $elem;
      }
    }
    if ($this->modifiers !== null) {
      foreach ($this->modifiers as $elem) {
        yield $elem;
      }
    }
    if ($this->typeAnnotation !== null) {
      yield $this->typeAnnotation;
    }
    if ($this->expression !== null) {
      yield $this->expression;
    }
  }

  public function acceptAsReference(/*mixed*/ $visitor) /*: mixed*/ {
    throw new Exception("ParameterDeclarations should always be children");
  }

  public function getReferences() /*: Continuation<INode>*/ {
    // UNSAFE
    yield break;
  }
}
}
