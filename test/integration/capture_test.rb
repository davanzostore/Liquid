# frozen_string_literal: true

require 'test_helper'

class CaptureTest < Minitest::Test
  include Liquid

  def test_captures_block_content_in_variable
    assert_template_result("test string", "{% capture 'var' %}test string{% endcapture %}{{var}}", {})
  end

  def test_capture_with_hyphen_in_variable_name
    template_source = <<~END_TEMPLATE
      {% capture this-thing %}Print this-thing{% endcapture -%}
      {{ this-thing -}}
    END_TEMPLATE
    assert_template_result("Print this-thing", template_source)
  end

  def test_capture_to_variable_from_outer_scope_if_existing
    template_source = <<~END_TEMPLATE
      {% assign var = '' -%}
      {% if true -%}
        {% capture var %}first-block-string{% endcapture -%}
      {% endif -%}
      {% if true -%}
        {% capture var %}test-string{% endcapture -%}
      {% endif -%}
      {{var-}}
    END_TEMPLATE
    assert_template_result("test-string", template_source)
  end

  def test_assigning_from_capture
    template_source = <<~END_TEMPLATE
      {% assign first = '' -%}
      {% assign second = '' -%}
      {% for number in (1..3) -%}
        {% capture first %}{{number}}{% endcapture -%}
        {% assign second = first -%}
      {% endfor -%}
      {{ first }}-{{ second -}}
    END_TEMPLATE
    assert_template_result("3-3", template_source)
  end

  def test_increment_assign_score_by_bytes_not_characters
    t = Template.parse("{% capture foo %}すごい{% endcapture %}")
    t.render!
    assert_equal(9, t.resource_limits.assign_score)
  end
end
