defmodule Bench.AuthorFactory do
  alias Bench.Authors.Author

  defmacro __using__(_opts) do
    quote do
      def author_factory do
        %Author{
          name: Faker.Person.name(),
          birth: Faker.Date.date_of_birth()
        }
      end
    end
  end
end
