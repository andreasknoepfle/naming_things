defmodule NamingThings.TranslationServices.Glosbe do
  alias HTTPotion, as: HTTP
  alias Poison.Parser, as: JSON

  def translate(query, from) do
    queries = [String.capitalize(query), String.downcase(query)]
    Enum.flat_map queries, fn(query) -> translate_term(query, from) end
  end

  defp translate_term(query, from) do
    query_glosbe(query, from)
    |> handle_query_response
  rescue
    _ in HTTP.HTTPError -> { :error, [] }
  end

  @glosbe_translation_url "https://glosbe.com/gapi/translate"
  defp query_glosbe(query, from) do
    HTTP.get @glosbe_translation_url,
             query: %{
               from: from,
               dest: "en",
               format: "json",
               phrase: query
             }
  end

  defp handle_query_response(%HTTP.Response{status_code: 200, body: body}) do
    body
    |> JSON.parse
    |> handle_parsed_response
  end

  defp handle_query_response(_) do
    { :error, [] }
  end

  defp handle_parsed_response({:ok, result = %{"result"=> "ok" }}) do
    case result do
      %{ "tuc" => phrases } -> handle_phrases(phrases)
      _ -> { :ok, [] }
    end
  end

  defp handle_parsed_response({:error, _ }) do
    { :error, [] }
  end

  defp handle_phrases(phrases) do
    Enum.filter_map phrases,
      fn(phrase) -> is_phrase?(phrase) end,
      fn(phrase) -> phrase["phrase"]["text"] end
  end

  defp is_phrase?(%{ "phrase" => %{ "text" => _ } }) do
    true
  end

  defp is_phrase?(_) do
    false
  end

end
