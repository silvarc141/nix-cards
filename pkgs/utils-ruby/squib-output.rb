require 'squib'

A4_WIDTH = 2490
A4_HEIGHT = 3510

def save_variants(printer_margin = 28, bleed = '1c')
  construct_output($output_dir, $output_variant, "cards-#{$card_type}-#{$card_side}", $card_side == 'back', printer_margin, bleed)
end

def construct_output(output_dir, variant, prefix, back, printer_margin, bleed)
  case variant
  when "pdf"
    # For some reason crop_marks cannot be disabled, breaking scaling when printing on defaults.
    # For CUPS, use -o "print-scaling=none" to override this behaviour and correct the scaling.
    save_pdf dir: output_dir, file: "#{prefix}.pdf", rtl: back, margin: printer_margin, width: A4_WIDTH, height: A4_HEIGHT
  when "pdf-pnp"
    save_pdf dir: output_dir, file: "#{prefix}.pdf", rtl: back, margin: printer_margin, width: A4_WIDTH, height: A4_HEIGHT, trim: bleed
  when "sheet"
    save_sheet dir: output_dir, prefix: prefix, rtl: back
  when "sheet-pnp"
    save_sheet dir: output_dir, prefix: prefix, rtl: back, trim: bleed, columns: 3
  when "images"
    save_png dir: output_dir, prefix: prefix
  when "images-pnp"
    save_png dir: output_dir, prefix: prefix, trim: bleed
  when "single"
    save_png range: 0, dir: output_dir, prefix: "#{prefix}-example", count_format: ''
  end
end
