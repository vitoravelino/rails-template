# frozen_string_literal: true

# rubocop:disable Naming/MethodName
class Operation < Micro::Case
  def Success(type = :ok, **result)
    super(type, result: result)
  end

  def Failure(type = :error, **result)
    super(type, result: result)
  end
end
