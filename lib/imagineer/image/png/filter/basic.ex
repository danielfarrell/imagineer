defmodule Imagineer.Image.PNG.Filter.Basic do
  alias Imagineer.Image.PNG
  alias PNG.Filter.Basic
  import PNG.Helpers, only: [ bytes_per_pixel: 1, bytes_per_row: 2, null_binary: 1 ]
  @none    0
  @sub     1
  @up      2
  @average 3
  @paeth   4

  @doc """
  Takes an image and its decompressed content. Returns the rows unfiltered with
  their respective index.

  Types are defined [here](http://www.w3.org/TR/PNG-Filters.html).
  """
  def unfilter(%PNG{scanlines: scanlines}=image) when is_list(scanlines) do
    # For unfiltering, the row prior to the first is assumed to be all 0s
    ghost_row = null_binary(bytes_per_row(image.color_format, image.width))
    unfilter(scanlines, ghost_row, 0, bytes_per_pixel(image.color_format), [])
  end

  defp unfilter([], _prior_row, _current_index, _bytes_per_pixel, unfiltered) do
    Enum.reverse unfiltered
  end

  defp unfilter([filtered_row | filtered_rows], prior_row, row_index, bytes_per_pixel, unfiltered) do
    unfiltered_row = unfilter_scanline(filtered_row, bytes_per_pixel, prior_row)
    unfilter(filtered_rows, unfiltered_row, row_index+1, bytes_per_pixel, [{row_index, unfiltered_row} | unfiltered])
  end

  defp unfilter_scanline(<<@none::size(8), row_content::binary>>, _bytes_per_pixel, _prior) do
    row_content
  end

  defp unfilter_scanline(<<@sub::size(8), row_content::binary>>, bytes_per_pixel, _prior) do
    Basic.Sub.unfilter(row_content, bytes_per_pixel)
  end

  defp unfilter_scanline(<<@up::size(8), row_content::binary>>, _bytes_per_pixel, prior_row) do
    Basic.Up.unfilter(row_content, prior_row)
  end

  defp unfilter_scanline(<<@average::size(8), row_content::binary>>, bytes_per_pixel, prior_row) do
    Basic.Average.unfilter(row_content, prior_row, bytes_per_pixel)
  end

  defp unfilter_scanline(<<@paeth::size(8), row_content::binary>>, bytes_per_pixel, prior_row) do
    Basic.Paeth.unfilter(row_content, prior_row, bytes_per_pixel)
  end
end
