cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
    expressionLib:
    - var split_numbers = function(line) {
          let splitted_line = line?line.split(/[\s,]+/).map(parseFloat):null;
          return (splitted_line && !!splitted_line.length)?splitted_line:null;
      };
    - var get_query_column = function(reduction, resolution) {
          if (reduction=="RNA") {
            return Array.from(split_numbers(resolution), r => "rna_res." + r);
          } else if (reduction=="ATAC") {
            return Array.from(split_numbers(resolution), r => "atac_res." + r);
          } else if (reduction=="WNN") {
            return Array.from(split_numbers(resolution), r => "wsnn_res." + r);
          }
      };


"sd:upstream":
  sc_tools_sample:
  - "sc-rna-cluster.cwl"
  - "sc-atac-cluster.cwl"
  - "sc-wnn-cluster.cwl"


inputs:

  alias:
    type: string
    label: "Experiment short name/alias"
    sd:preview:
      position: 1

  query_data_rds:
    type: File
    label: "Experiment run through any of the Single-cell Cluster Analysis"
    doc: |
      Path to the RDS file to load Seurat object from. This file should include
      genes expression and/or chromatin accessibility information stored in the RNA
      and/or ATAC assays correspondingly. Additionally, 'rnaumap', and/or 'atacumap',
      and/or 'wnnumap' dimensionality reductions should be present.
    "sd:upstreamSource": "sc_tools_sample/seurat_data_rds"
    "sd:localLabel": true

  query_reduction:
    type:
    - "null"
    - type: enum
      symbols:
      - "RNA"
      - "ATAC"
      - "WNN"
    default: "RNA"
    label: "Select clusters based on"
    doc: |
      If set to 'RNA' selects query_source_column with 'rna_res' prefix.
      If set to 'ATAC' selects query_source_column with 'atac_res' prefix.
      If set to 'WNN' selects query_source_column with 'wsnn_res' prefix.
  
  query_resolution:
    type: string
    label: "Comma or space separated list of clustering resolutions to harmonize"
    doc: |
      Defines the suffix used when constructing values for 'query_source_column'

  barcodes_data:
    type: File?
    label: "Optional TSV/CSV file to prefilter and extend metadata be barcodes. First column should be named as 'barcode'"
    doc: |
      Path to the TSV/CSV file to optionally prefilter and extend Seurat object
      metadata be selected barcodes. First column should be named as 'barcode'.
      If file includes any other columns they will be added to the Seurat object
      metadata ovewriting the existing ones if those are present.
      Default: all cells used, no extra metadata is added

  color_theme:
    type:
    - "null"
    - type: enum
      symbols:
      - "gray"
      - "bw"
      - "linedraw"
      - "light"
      - "dark"
      - "minimal"
      - "classic"
      - "void"
    default: "classic"
    label: "Color theme for all generated plots"
    doc: |
      Color theme for all generated plots. One of gray, bw, linedraw, light,
      dark, minimal, classic, void.
      Default: classic
    "sd:layout":
      advanced: true

  threads:
    type:
    - "null"
    - type: enum
      symbols:
      - "1"
      - "2"
      - "3"
      - "4"
      - "5"
      - "6"
    default: "4"
    label: "Number of cores/cpus to use"
    doc: |
      Parallelization parameter to define the
      number of cores/CPUs that can be utilized
      simultaneously.
      Default: 4
    "sd:layout":
      advanced: true


outputs:

  umap_tril_rd_rnaumap_plot_png:
    type: File?
    outputSource: triangulate/umap_tril_rd_rnaumap_plot_png
    label: "Cells UMAP with integrated labels (rnaumap dim. reduction)"
    doc: |
      Cells UMAP with integrated labels (rnaumap dim. reduction).
      PNG format
    "sd:visualPlugins":
    - image:
        tab: "RNA"
        Caption: "Cells UMAP with integrated labels"

  umap_tric_rd_rnaumap_plot_png:
    type: File?
    outputSource: triangulate/umap_tric_rd_rnaumap_plot_png
    label: "Cells UMAP with integration confidence scores (rnaumap dim. reduction)"
    doc: |
      Cells UMAP with integration confidence scores (rnaumap dim. reduction).
      PNG format
    "sd:visualPlugins":
    - image:
        tab: "RNA"
        Caption: "Cells UMAP with integration confidence scores"

  umap_tria_rd_rnaumap_plot_png:
    type: File?
    outputSource: triangulate/umap_tria_rd_rnaumap_plot_png
    label: "Cells UMAP with winning annotations (rnaumap dim. reduction)"
    doc: |
      Cells UMAP with winning annotations (rnaumap dim. reduction).
      PNG format
    "sd:visualPlugins":
    - image:
        tab: "RNA"
        Caption: "Cells UMAP with winning annotations"

  umap_tril_rd_atacumap_plot_png:
    type: File?
    outputSource: triangulate/umap_tril_rd_atacumap_plot_png
    label: "Cells UMAP with integrated labels (atacumap dim. reduction)"
    doc: |
      Cells UMAP with integrated labels (atacumap dim. reduction).
      PNG format
    "sd:visualPlugins":
    - image:
        tab: "ATAC"
        Caption: "Cells UMAP with integrated labels"

  umap_tric_rd_atacumap_plot_png:
    type: File?
    outputSource: triangulate/umap_tric_rd_atacumap_plot_png
    label: "Cells UMAP with integration confidence scores (atacumap dim. reduction)"
    doc: |
      Cells UMAP with integration confidence scores (atacumap dim. reduction).
      PNG format
    "sd:visualPlugins":
    - image:
        tab: "ATAC"
        Caption: "Cells UMAP with integration confidence scores"

  umap_tria_rd_atacumap_plot_png:
    type: File?
    outputSource: triangulate/umap_tria_rd_atacumap_plot_png
    label: "Cells UMAP with winning annotations (atacumap dim. reduction)"
    doc: |
      Cells UMAP with winning annotations (atacumap dim. reduction).
      PNG format
    "sd:visualPlugins":
    - image:
        tab: "ATAC"
        Caption: "Cells UMAP with winning annotations"

  umap_tril_rd_wnnumap_plot_png:
    type: File?
    outputSource: triangulate/umap_tril_rd_wnnumap_plot_png
    label: "Cells UMAP with integrated labels (wnnumap dim. reduction)"
    doc: |
      Cells UMAP with integrated labels (wnnumap dim. reduction).
      PNG format
    "sd:visualPlugins":
    - image:
        tab: "WNN"
        Caption: "Cells UMAP with integrated labels"

  umap_tric_rd_wnnumap_plot_png:
    type: File?
    outputSource: triangulate/umap_tric_rd_wnnumap_plot_png
    label: "Cells UMAP with integration confidence scores (wnnumap dim. reduction)"
    doc: |
      Cells UMAP with integration confidence scores (wnnumap dim. reduction).
      PNG format
    "sd:visualPlugins":
    - image:
        tab: "WNN"
        Caption: "Cells UMAP with integration confidence scores"

  umap_tria_rd_wnnumap_plot_png:
    type: File?
    outputSource: triangulate/umap_tria_rd_wnnumap_plot_png
    label: "Cells UMAP with winning annotations (wnnumap dim. reduction)"
    doc: |
      Cells UMAP with winning annotations (wnnumap dim. reduction).
      PNG format
    "sd:visualPlugins":
    - image:
        tab: "WNN"
        Caption: "Cells UMAP with winning annotations"

  ucsc_cb_html_data:
    type: Directory
    outputSource: triangulate/ucsc_cb_html_data
    label: "UCSC Cell Browser (data)"
    doc: |
      UCSC Cell Browser html data.

  ucsc_cb_html_file:
    type: File
    outputSource: triangulate/ucsc_cb_html_file
    label: "UCSC Cell Browser"
    doc: |
      UCSC Cell Browser html index.
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  seurat_data_rds:
    type: File
    outputSource: triangulate/seurat_data_rds
    label: "Seurat object in RDS format"
    doc: |
      Seurat object.
      RDS format.

  seurat_rna_data_cloupe:
    type: File?
    outputSource: triangulate/seurat_rna_data_cloupe
    label: "Seurat object in Loupe format"
    doc: |
      Seurat object.
      RNA counts.
      Loupe format.

  pdf_plots:
    type: File
    outputSource: compress_pdf_plots/compressed_folder
    label: "Compressed folder with all PDF plots"
    doc: |
      Compressed folder with all PDF plots.

  triangulate_stdout_log:
    type: File
    outputSource: triangulate/stdout_log
    label: "Output log"
    doc: |
      Stdout log from the triangulate step.

  triangulate_stderr_log:
    type: File
    outputSource: triangulate/stderr_log
    label: "Error log"
    doc: |
      Stderr log from the triangulate step.


steps:

  triangulate:
    run: ../tools/sc-triangulate.cwl
    in:
      query_data_rds: query_data_rds
      barcodes_data: barcodes_data
      query_source_column:
        source: [query_reduction, query_resolution]
        valueFrom: $(get_query_column(self[0], self[1]))
      verbose:
        default: true
      export_ucsc_cb:
        default: true
      export_loupe_data:
        default: true
      export_pdf_plots:
        default: true
      color_theme: color_theme
      parallel_memory_limit:
        default: 32
      vector_memory_limit:
        default: 96
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
    - umap_tril_rd_rnaumap_plot_png
    - umap_tril_rd_atacumap_plot_png
    - umap_tril_rd_wnnumap_plot_png
    - umap_tria_rd_rnaumap_plot_png
    - umap_tria_rd_atacumap_plot_png
    - umap_tria_rd_wnnumap_plot_png
    - umap_tric_rd_rnaumap_plot_png
    - umap_tric_rd_atacumap_plot_png
    - umap_tric_rd_wnnumap_plot_png
    - umap_tril_rd_rnaumap_plot_pdf
    - umap_tril_rd_atacumap_plot_pdf
    - umap_tril_rd_wnnumap_plot_pdf
    - umap_tria_rd_rnaumap_plot_pdf
    - umap_tria_rd_atacumap_plot_pdf
    - umap_tria_rd_wnnumap_plot_pdf
    - umap_tric_rd_rnaumap_plot_pdf
    - umap_tric_rd_atacumap_plot_pdf
    - umap_tric_rd_wnnumap_plot_pdf
    - ucsc_cb_html_data
    - ucsc_cb_html_file
    - seurat_data_rds
    - seurat_rna_data_cloupe
    - stdout_log
    - stderr_log

  folder_pdf_plots:
    run: ../tools/files-to-folder.cwl
    in:
      input_files:
        source:
        - triangulate/umap_tril_rd_rnaumap_plot_pdf
        - triangulate/umap_tril_rd_atacumap_plot_pdf
        - triangulate/umap_tril_rd_wnnumap_plot_pdf
        - triangulate/umap_tria_rd_rnaumap_plot_pdf
        - triangulate/umap_tria_rd_atacumap_plot_pdf
        - triangulate/umap_tria_rd_wnnumap_plot_pdf
        - triangulate/umap_tric_rd_rnaumap_plot_pdf
        - triangulate/umap_tric_rd_atacumap_plot_pdf
        - triangulate/umap_tric_rd_wnnumap_plot_pdf
        valueFrom: $(self.flat().filter(n => n))
      folder_basename:
        default: "pdf_plots"
    out:
    - folder

  compress_pdf_plots:
    run: ../tools/tar-compress.cwl
    in:
      folder_to_compress: folder_pdf_plots/folder
    out:
    - compressed_folder


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf

label: "Single-Cell Label Integration Analysis"
s:name: "Single-Cell Label Integration Analysis"
s:alternateName: "Harmonizes conflicting annotations in single-cell genomics studies"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows-datirium/master/workflows/sc-triangulate.cwl
s:codeRepository: https://github.com/Barski-lab/workflows-datirium
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Cincinnati Children's Hospital Medical Center"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: "45229"
    s:streetAddress: "3333 Burnet Ave"
    s:telephone: "+1(513)636-4200"
  s:logo: "https://www.cincinnatichildrens.org/-/media/cincinnati%20childrens/global%20shared/childrens-logo-new.png"
  s:department:
  - class: s:Organization
    s:legalName: "Allergy and Immunology"
    s:department:
    - class: s:Organization
      s:legalName: "Barski Research Lab"
      s:member:
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:misha.kotliar@gmail.com
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898


doc: |
  Single-Cell Label Integration Analysis

  Harmonizes conflicting annotations in single-cell genomics studies.