module JobsHelper
  # groupint is optional, but needs to be provided as [grouping]
  def make_lightbox_link( imagefile, linktext, grouping = "" )
    "<a href=\"#{imagefile}\"
    rel=\"lightbox#{grouping}\" 
    title=\"&lt;a href='#{imagefile}'&gt;right
    click here to download&lt;/a&gt;\"
    >#{linktext}</a>"
  end
end
