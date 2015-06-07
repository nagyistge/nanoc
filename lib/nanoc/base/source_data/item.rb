module Nanoc::Int
  # @api private
  class Item < ::Nanoc::Int::Document
    # @return [Array<Nanoc::Int::ItemRep>] This item’s list of item reps
    attr_reader :reps

    # @return [Nanoc::Int::Item, nil] The parent item of this item. This can be
    #   nil even for non-root items.
    attr_accessor :parent

    # @return [Array<Nanoc::Int::Item>] The child items of this item
    attr_accessor :children

    # @see Document#initialize
    def initialize(content, attributes, identifier)
      super

      @parent = nil
      @children = []
      @reps = []
      @forced_outdated_status = ForcedOutdatedStatus.new
    end

    # Returns the rep with the given name.
    #
    # @param [Symbol] rep_name The name of the representation to return
    #
    # @return [Nanoc::Int::ItemRep] The representation with the given name
    def rep_named(rep_name)
      @reps.find { |r| r.name == rep_name }
    end

    # Returns the compiled content from a given representation and a given
    # snapshot. This is a convenience method that makes fetching compiled
    # content easier.
    #
    # @option params [String] :rep (:default) The name of the representation
    #   from which the compiled content should be fetched. By default, the
    #   compiled content will be fetched from the default representation.
    #
    # @option params [String] :snapshot The name of the snapshot from which to
    #   fetch the compiled content. By default, the returned compiled content
    #   will be the content compiled right before the first layout call (if
    #   any).
    #
    # @return [String] The compiled content of the given rep (or the default
    #   rep if no rep is specified) at the given snapshot (or the default
    #   snapshot if no snapshot is specified)
    #
    # @see ItemRep#compiled_content
    def compiled_content(params = {})
      # Get rep
      rep_name = params[:rep] || :default
      rep = reps.find { |r| r.name == rep_name }
      if rep.nil?
        raise Nanoc::Int::Errors::Generic,
          "No rep named #{rep_name.inspect} was found."
      end

      # Get rep's content
      rep.compiled_content(params)
    end

    # Returns the path from a given representation. This is a convenience
    # method that makes fetching the path of a rep easier.
    #
    # @option params [String] :rep (:default) The name of the representation
    #   from which the path should be fetched. By default, the path will be
    #   fetched from the default representation.
    #
    # @return [String] The path of the given rep ( or the default rep if no
    #   rep is specified)
    def path(params = {})
      rep_name = params[:rep] || :default

      # Get rep
      rep = reps.find { |r| r.name == rep_name }
      if rep.nil?
        raise Nanoc::Int::Errors::Generic,
          "No rep named #{rep_name.inspect} was found."
      end

      # Get rep's path
      rep.path
    end

    # Returns an object that can be used for uniquely identifying objects.
    #
    # @api private
    #
    # @return [Object] An unique reference to this object
    def reference
      [:item, identifier.to_s]
    end

    # Hack to allow a frozen item to still have modifiable frozen status.
    #
    # FIXME: Remove this.
    class ForcedOutdatedStatus
      attr_accessor :bool

      def initialize
        @bool = false
      end

      def freeze
      end
    end

    # @api private
    def forced_outdated=(bool)
      @forced_outdated_status.bool = bool
    end

    # @api private
    def forced_outdated?
      @forced_outdated_status.bool
    end
  end
end
