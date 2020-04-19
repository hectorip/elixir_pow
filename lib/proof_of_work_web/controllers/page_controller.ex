defmodule ProofOfWorkWeb.PageController do
  use ProofOfWorkWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def proof(conn, params = %{"q" => q, "diff" => diff}) do
    target = :math.pow(2, 256 - String.to_integer(diff))

    {nonce, hash, value, target, content} = pow(q, target)
    json(conn, %{
      nonce: nonce,
      hash: hash,
      value: value,
      target: target,
      content: content
    })
  end

  def proof(conn, params) do
    q = UUID.uuid1()
    proof(conn, Map.put(params, "q", q))
  end

  def proof_parallel(conn, %{"diff" => diff}) do
    q = UUID.uuid1()
    target = :math.pow(2, 256 - String.to_integer(diff))
    {nonce, hash, value, target, content} = pow_parallel(q, target)
    json(conn, %{
      nonce: nonce,
      hash: hash,
      value: value,
      target: target,
      content: content
    })
  end

  def pow(content, target, nonce \\ 0) do
    content_nonce = "#{content}#{nonce}"
    hash = :crypto.hash(:sha256, content_nonce)
      |> Base.encode16()

    value = hash |> String.to_integer(16)
    if value < target do
      {nonce, hash, value, target, content}
    else
      pow(content, target, nonce + 1)
    end
  end

  def pow_worker(content, target, nonce, parent) do
    IO.puts("Worker starting #{nonce}")
    IO.inspect(parent)
    result = pow(content, target, nonce)
    send(parent, {:result, result})
  end

  def pow_parallel(content, target) do
    max_nonce = 1000_000_000
    workers = 4
    size = max_nonce / workers
    pid = self()
    0..(workers-1)
    |> Enum.map(fn worker ->
      spawn_link(ProofOfWorkWeb.PageController,:pow_worker, [content, target, worker * size, pid])
    end)
    receive do
      {:result, value} ->
        value
    end
  end

end
