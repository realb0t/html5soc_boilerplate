module BeforeOnlyFilter

  def before_only(*args, &block)

    if args.size == 1 && args.is_a?(Array)
      paths = args[0]
    else
      paths = args
    end

    paths.each do |path|
      before path do
        instance_eval(&block)
      end
    end

  end

end
