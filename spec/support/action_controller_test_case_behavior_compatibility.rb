module ActionControllerTestCaseBehaviorCompatibility
  def get(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def post(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def patch(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def put(action, **args)
    if Rails.version <= '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def delete(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def head(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def __strongbolt_params_compatibility(**args)
    parameters, session, flash = args
    parameters ||= {}
    return parameters.delete(:params), session, flash
  end
end

module ActionController::TestCase::Behavior
  prepend ActionControllerTestCaseBehaviorCompatibility
end
