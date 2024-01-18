cwlVersion: v1.0
class: Workflow


requirements:
- class: SubworkflowFeatureRequirement
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
- class: MultipleInputFeatureRequirement


'sd:upstream':
  sc_rnaseq_sample:
  - "cellranger-arc-count.cwl"
  genome_indices:
  - "cellranger-mkref.cwl"


inputs:

  alias:
    type: string
    label: "Analysis name"
    sd:preview:
      position: 1

  gex_molecule_info_h5:
    type: File[]
    label: "Cell Ranger ARC Sample"
    doc: |
      Any "Cell Ranger ARC Sample" that
      produces RNA molecule-level data,
      ATAC fragments, and ATAC and RNA
      barcode metrics files.
    'sd:upstreamSource': "sc_rnaseq_sample/gex_molecule_info_h5"
    'sd:localLabel': true

  gem_well_labels:
    type: string[]
    'sd:upstreamSource': "sc_rnaseq_sample/alias"

  atac_fragments_file_from_count:
    type: File[]
    secondaryFiles:
    - .tbi
    'sd:upstreamSource': "sc_rnaseq_sample/atac_fragments_file"

  barcode_metrics_report:
    type: File[]
    'sd:upstreamSource': "sc_rnaseq_sample/barcode_metrics_report"

  indices_folder:
    type: Directory
    label: "Genome type"
    doc: |
      Reference genome package created
      with cellranger-arc mkref command.
    'sd:upstreamSource': "genome_indices/arc_indices_folder"
    'sd:localLabel': true

  memory_limit:
    type: int?
    default: 20
    'sd:upstreamSource': "genome_indices/memory_limit"

  normalization_mode:
    type:
    - "null"
    - type: enum
      symbols:
      - "none"
      - "depth"
    default: "none"
    label: "Library depth normalization"
    doc: |
      When "depth" normalization is 
      selected, subsample reads from
      higher-depth GEM wells until we
      equalize the 1) median number
      of unique fragments per cell for
      each ATAC library, 2) mean number
      of reads that are confidently
      mapped to the transcriptome per
      cell for each gene expression
      library.
    'sd:layout':
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
    label: "Cores/CPUs"
    doc: |
      Parallelization parameter to define the
      number of cores/CPUs that can be utilized
      simultaneously.
      Default: 4
    'sd:layout':
      advanced: true


outputs:

  web_summary_report:
    type: File
    outputSource: aggregate_counts/web_summary_report
    label: "Cell Ranger Summary"
    doc: |
      Report generated by Cell Ranger
    'sd:visualPlugins':
    - linkList:
        tab: 'Overview'
        target: "_blank"

  cellbrowser_report:
    type: File
    outputSource: cellbrowser_build/index_html_file
    label: "UCSC Cell Browser"
    doc: |
      UCSC Cell Browser HTML index file
    'sd:visualPlugins':
    - linkList:
        tab: 'Overview'
        target: "_blank"

  metrics_summary_report:
    type: File
    outputSource: aggregate_counts/metrics_summary_report
    label: "Run summary metrics"
    doc: |
      Cell Ranger generated run summary
      metrics in CSV format

  aggregation_metadata:
    type: File
    outputSource: aggregate_counts/aggregation_metadata
    label: "Aggregation metadata"
    doc: |
      Aggregation metadata file
      in CSV format

  grouping_data:
    type: File
    outputSource: aggregate_counts/grouping_data
    label: "Example of datasets grouping"
    doc: |
      Example of TSV file to define datasets grouping

  filtered_feature_bc_matrix_folder:
    type: File
    outputSource: compress_filtered_feature_bc_matrix_folder/compressed_folder
    label: "Filtered feature barcode matrix, MEX"
    doc: |
      Filtered feature barcode matrix stored
      as a CSC sparse matrix in MEX format.
      The rows consist of all the gene and
      peak features concatenated together
      (identical to raw feature barcode
      matrix) and the columns are restricted
      to those barcodes that are identified
      as cells.

  filtered_feature_bc_matrix_h5:
    type: File
    outputSource: aggregate_counts/filtered_feature_bc_matrix_h5
    label: "Filtered feature barcode matrix, HDF5"
    doc: |
      Filtered feature barcode matrix stored
      as a CSC sparse matrix in hdf5 format.
      The rows consist of all the gene and
      peak features concatenated together
      (identical to raw feature barcode
      matrix) and the columns are restricted
      to those barcodes that are identified
      as cells.

  raw_feature_bc_matrices_folder:
    type: File
    outputSource: compress_raw_feature_bc_matrices_folder/compressed_folder
    label: "Raw feature barcode matrix, MEX"
    doc: |
      Raw feature barcode matrix stored as
      a CSC sparse matrix in MEX format.
      The rows consist of all the gene and
      peak features concatenated together
      and the columns consist of all observed
      barcodes with non-zero signal for
      either ATAC or gene expression.

  raw_feature_bc_matrices_h5:
    type: File
    outputSource: aggregate_counts/raw_feature_bc_matrices_h5
    label: "Raw feature barcode matrix, HDF5"
    doc: |
      Raw feature barcode matrix stored as
      a CSC sparse matrix in hdf5 format.
      The rows consist of all the gene and
      peak features concatenated together
      and the columns consist of all observed
      barcodes with non-zero signal for
      either ATAC or gene expression.

  secondary_analysis_report_folder:
    type: File
    outputSource: compress_secondary_analysis_report_folder/compressed_folder
    label: "Secondary analysis"
    doc: |
      Various secondary analyses that
      utilize the ATAC, RNA data, and
      their linkage: dimensionality
      reduction and clustering results
      for the ATAC and RNA data,
      differential expression, and
      differential accessibility for all
      clustering results above and linkage
      between ATAC and RNA data.

  loupe_browser_track:
    type: File
    outputSource: aggregate_counts/loupe_browser_track
    label: "Loupe Browser visualization"
    doc: |
      Loupe Browser visualization file
      with all the analysis outputs

  atac_fragments_file:
    type: File
    outputSource: aggregate_counts/atac_fragments_file
    label: "ATAC fragments"
    doc: |
      Count and barcode information for
      every ATAC fragment observed in
      the experiment in TSV format.

  atac_peaks_bed_file:
    type: File
    outputSource: aggregate_counts/atac_peaks_bed_file
    label: "ATAC peaks"
    doc: |
      Locations of open-chromatin regions
      identified in this sample. These
      regions are referred to as "peaks".

  atac_peak_annotation_file:
    type: File
    outputSource: aggregate_counts/atac_peak_annotation_file
    label: "ATAC peaks annotations"
    doc: |
      Annotations of peaks based on
      genomic proximity alone. Note,
      that these are not functional
      annotations and they do not make
      use of linkage with RNA data.

  aggregate_counts_stdout_log:
    type: File
    outputSource: aggregate_counts/stdout_log
    label: "Output log, cellranger-arc aggr step"
    doc: |
      stdout log generated by cellranger-arc aggr

  aggregate_counts_stderr_log:
    type: File
    outputSource: aggregate_counts/stderr_log
    label: "Error log, cellranger-arc aggr step"
    doc: |
      stderr log generated by cellranger-arc aggr

  html_data_folder:
    type: Directory
    outputSource: cellbrowser_build/html_data
    label: "UCSC Cell Browser data"
    doc: |
      Directory with UCSC Cell Browser
      data


steps:

  aggregate_counts:
    run: ../tools/cellranger-arc-aggr.cwl
    in:
      atac_fragments_file_from_count: atac_fragments_file_from_count
      barcode_metrics_report: barcode_metrics_report
      gex_molecule_info_h5: gex_molecule_info_h5
      gem_well_labels: gem_well_labels
      indices_folder: indices_folder
      normalization_mode: normalization_mode
      threads:
        source: threads
        valueFrom: $(parseInt(self))
      memory_limit: memory_limit
      virt_memory_limit: memory_limit
    out:
    - web_summary_report
    - metrics_summary_report
    - atac_fragments_file
    - atac_peaks_bed_file
    - atac_peak_annotation_file
    - secondary_analysis_report_folder
    - filtered_feature_bc_matrix_folder
    - filtered_feature_bc_matrix_h5
    - raw_feature_bc_matrices_folder
    - raw_feature_bc_matrices_h5
    - aggregation_metadata
    - grouping_data
    - loupe_browser_track
    - stdout_log
    - stderr_log

  compress_filtered_feature_bc_matrix_folder:
    run: ../tools/tar-compress.cwl
    in:
      folder_to_compress: aggregate_counts/filtered_feature_bc_matrix_folder
    out:
    - compressed_folder

  compress_raw_feature_bc_matrices_folder:
    run: ../tools/tar-compress.cwl
    in:
      folder_to_compress: aggregate_counts/raw_feature_bc_matrices_folder
    out:
    - compressed_folder

  compress_secondary_analysis_report_folder:
    run: ../tools/tar-compress.cwl
    in:
      folder_to_compress: aggregate_counts/secondary_analysis_report_folder
    out:
    - compressed_folder

  cellbrowser_build:
    run: ../tools/cellbrowser-build-cellranger-arc.cwl
    in:
      secondary_analysis_report_folder: aggregate_counts/secondary_analysis_report_folder
      filtered_feature_bc_matrix_folder: aggregate_counts/filtered_feature_bc_matrix_folder
      aggregation_metadata: aggregate_counts/aggregation_metadata
    out:
    - html_data
    - index_html_file


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf


label: "Cell Ranger Aggregate (RNA+ATAC)"
s:name: "Cell Ranger Aggregate (RNA+ATAC)"
s:alternateName: "Combines outputs from multiple runs of Cell Ranger Count (RNA+ATAC) pipeline"

s:downloadUrl: https://raw.githubusercontent.com/datirium/workflows/master/workflows/cellranger-arc-aggr.cwl
s:codeRepository: https://github.com/datirium/workflows
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
  Cell Ranger Aggregate (RNA+ATAC)

  Combines outputs from multiple runs of “Cell Ranger Count (RNA+ATAC)”
  pipeline. The results of this workflow are primarily used in
  “Single-Cell Multiome ATAC and RNA-Seq Filtering Analysis” pipeline.
