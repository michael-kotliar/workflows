cwlVersion: v1.0
class: CommandLineTool


requirements:
- class: InlineJavascriptRequirement
- class: EnvVarRequirement
  envDef:
    R_MAX_VSIZE: $((inputs.vector_memory_limit * 1000000000).toString())


hints:
- class: DockerRequirement
  dockerPull: biowardrobe2/sc-tools:v0.0.27


inputs:

  query_data_rds:
    type: File
    inputBinding:
      prefix: "--query"
    doc: |
      Path to the RDS file to load Seurat object from. This file should
      include genes expression information stored in the RNA assay and
      dimensionality reduction specified in the --reduction parameter.

  reduction:
    type: string?
    inputBinding:
      prefix: "--reduction"
    doc: |
      Dimensionality reduction to be used in the trajectory analysis.
      Default: pca

  dimensions:
    type:
    - "null"
    - int
    - int[]
    inputBinding:
      prefix: "--dimensions"
    doc: |
      Dimensionality to use (from 1 to 50). If single value N is provided,
      use from 1 to N dimensions. If multiple values are provided, subset
      to only selected dimensions. May fail if user specified more dimensions
      than it was available in the selected --reduction.
      Default: use all available dimensions

  query_source_column:
    type: string
    inputBinding:
      prefix: "--source"
    doc: |
      Column from the metadata of the loaded
      Seurat object to select clusters from

  barcodes_data:
    type: File?
    inputBinding:
      prefix: "--barcodes"
    doc: |
      Path to the TSV/CSV file to optionally prefilter and extend Seurat object
      metadata be selected barcodes. First column should be named as 'barcode'.
      If file includes any other columns they will be added to the Seurat object
      metadata ovewriting the existing ones if those are present.
      Default: all cells used, no extra metadata is added

  trajectory_start:
    type: string?
    inputBinding:
      prefix: "--start"
    doc: |
      Value from the metadata column defined with --source
      parameter to set the starting point for the trajectory.
      Default: defined automatically

  predictive_genes:
    type: int?
    inputBinding:
      prefix: "--ngenes"
    doc: |
      Number of the most predictive genes to be shows
      on the gene expression heatmap. Default: 50

  export_pdf_plots:
    type: boolean?
    inputBinding:
      prefix: "--pdf"
    doc: |
      Export plots in PDF.
      Default: false

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
    inputBinding:
      prefix: "--theme"
    doc: |
      Color theme for all generated plots. One of gray, bw, linedraw, light,
      dark, minimal, classic, void.
      Default: classic

  verbose:
    type: boolean?
    inputBinding:
      prefix: "--verbose"
    doc: |
      Print debug information.
      Default: false

  export_h5seurat_data:
    type: boolean?
    inputBinding:
      prefix: "--h5seurat"
    doc: |
      Save Seurat data to h5seurat file.
      Default: false

  export_h5ad_data:
    type: boolean?
    inputBinding:
      prefix: "--h5ad"
    doc: |
      Save Seurat data to h5ad file.
      Default: false

  export_ucsc_cb:
    type: boolean?
    inputBinding:
      prefix: "--cbbuild"
    doc: |
      Export results to UCSC Cell Browser. Default: false

  output_prefix:
    type: string?
    inputBinding:
      prefix: "--output"
    doc: |
      Output prefix.
      Default: ./sc

  parallel_memory_limit:
    type: int?
    inputBinding:
      prefix: "--memory"
    doc: |
      Maximum memory in GB allowed to be shared between the workers
      when using multiple --cpus.
      Default: 32

  vector_memory_limit:
    type: int?
    default: 128
    doc: |
      Maximum vector memory in GB allowed to be used by R.
      Default: 128

  threads:
    type: int?
    inputBinding:
      prefix: "--cpus"
    doc: |
      Number of cores/cpus to use.
      Default: 1


outputs:

  trjc_gr_clst_plot_png:
    type: File?
    outputBinding:
      glob: "*_trjc_gr_clst.png"
    doc: |
      Trajectory plot, colored by cluster.
      PNG format

  trjc_gr_clst_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_trjc_gr_clst.pdf"
    doc: |
      Trajectory plot, colored by cluster.
      PDF format

  trjc_pstm_plot_png:
    type: File?
    outputBinding:
      glob: "*_trjc_pstm.png"
    doc: |
      Trajectory plot, colored by pseudotime.
      PNG format

  trjc_pstm_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_trjc_pstm.pdf"
    doc: |
      Trajectory plot, colored by pseudotime.
      PDF format

  grph_gr_clst_plot_png:
    type: File?
    outputBinding:
      glob: "*_grph_gr_clst.png"
    doc: |
      Trajectory graph, colored by cluster.
      PNG format

  grph_gr_clst_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_grph_gr_clst.pdf"
    doc: |
      Trajectory graph, colored by cluster.
      PDF format

  grph_pstm_plot_png:
    type: File?
    outputBinding:
      glob: "*_grph_pstm.png"
    doc: |
      Trajectory graph, colored by pseudotime.
      PNG format

  grph_pstm_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_grph_pstm.pdf"
    doc: |
      Trajectory graph, colored by pseudotime.
      PDF format

  dndr_gr_clst_plot_png:
    type: File?
    outputBinding:
      glob: "*_dndr_gr_clst.png"
    doc: |
      Dendrogram plot, colored by cluster.
      PNG format

  dndr_gr_clst_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_dndr_gr_clst.pdf"
    doc: |
      Dendrogram plot, colored by cluster.
      PDF format

  dndr_pstm_plot_png:
    type: File?
    outputBinding:
      glob: "*_dndr_pstm.png"
    doc: |
      Dendrogram plot, colored by pseudotime.
      PNG format

  dndr_pstm_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_dndr_pstm.pdf"
    doc: |
      Dendrogram plot, colored by pseudotime.
      PDF format

  tplg_plot_png:
    type: File?
    outputBinding:
      glob: "*_tplg.png"
    doc: |
      Topology plot.
      PNG format

  tplg_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_tplg.pdf"
    doc: |
      Topology plot.
      PDF format

  xpr_htmp_plot_png:
    type: File?
    outputBinding:
      glob: "*_xpr_htmp.png"
    doc: |
      Gene expression heatmap.
      PNG format

  xpr_htmp_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_xpr_htmp.pdf"
    doc: |
      Gene expression heatmap.
      PDF format

  umap_rd_rnaumap_plot_png:
    type: File?
    outputBinding:
      glob: "*_umap_rd_rnaumap.png"
    doc: |
      UMAP, colored by pseudotime, RNA.
      PNG format

  umap_rd_rnaumap_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_umap_rd_rnaumap.pdf"
    doc: |
      UMAP, colored by pseudotime, RNA.
      PDF format

  umap_rd_atacumap_plot_png:
    type: File?
    outputBinding:
      glob: "*_umap_rd_atacumap.png"
    doc: |
      UMAP, colored by pseudotime, ATAC.
      PNG format

  umap_rd_atacumap_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_umap_rd_atacumap.pdf"
    doc: |
      UMAP, colored by pseudotime, ATAC.
      PDF format

  umap_rd_wnnumap_plot_png:
    type: File?
    outputBinding:
      glob: "*_umap_rd_wnnumap.png"
    doc: |
      UMAP, colored by pseudotime, WNN.
      PNG format

  umap_rd_wnnumap_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_umap_rd_wnnumap.pdf"
    doc: |
      UMAP, colored by pseudotime, WNN.
      PDF format

  umap_spl_idnt_rd_rnaumap_plot_png:
    type: File?
    outputBinding:
      glob: "*_umap_spl_idnt_rd_rnaumap.png"
    doc: |
      UMAP, colored by pseudotime,
      split by dataset, RNA.
      PNG format

  umap_spl_idnt_rd_rnaumap_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_umap_spl_idnt_rd_rnaumap.pdf"
    doc: |
      UMAP, colored by pseudotime,
      split by dataset, RNA.
      PDF format

  umap_spl_idnt_rd_atacumap_plot_png:
    type: File?
    outputBinding:
      glob: "*_umap_spl_idnt_rd_atacumap.png"
    doc: |
      UMAP, colored by pseudotime,
      split by dataset, ATAC.
      PNG format

  umap_spl_idnt_rd_atacumap_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_umap_spl_idnt_rd_atacumap.pdf"
    doc: |
      UMAP, colored by pseudotime,
      split by dataset, ATAC.
      PDF format

  umap_spl_idnt_rd_wnnumap_plot_png:
    type: File?
    outputBinding:
      glob: "*_umap_spl_idnt_rd_wnnumap.png"
    doc: |
      UMAP, colored by pseudotime,
      split by dataset, WNN.
      PNG format

  umap_spl_idnt_rd_wnnumap_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_umap_spl_idnt_rd_wnnumap.pdf"
    doc: |
      UMAP, colored by pseudotime,
      split by dataset, WNN.
      PDF format

  umap_spl_cnd_rd_rnaumap_plot_png:
    type: File?
    outputBinding:
      glob: "*_umap_spl_cnd_rd_rnaumap.png"
    doc: |
      UMAP, colored by pseudotime,
      split by grouping condition, RNA.
      PNG format

  umap_spl_cnd_rd_rnaumap_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_umap_spl_cnd_rd_rnaumap.pdf"
    doc: |
      UMAP, colored by pseudotime,
      split by grouping condition, RNA.
      PDF format

  umap_spl_cnd_rd_atacumap_plot_png:
    type: File?
    outputBinding:
      glob: "*_umap_spl_cnd_rd_atacumap.png"
    doc: |
      UMAP, colored by pseudotime,
      split by grouping condition, ATAC.
      PNG format

  umap_spl_cnd_rd_atacumap_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_umap_spl_cnd_rd_atacumap.pdf"
    doc: |
      UMAP, colored by pseudotime,
      split by grouping condition, ATAC.
      PDF format

  umap_spl_cnd_rd_wnnumap_plot_png:
    type: File?
    outputBinding:
      glob: "*_umap_spl_cnd_rd_wnnumap.png"
    doc: |
      UMAP, colored by pseudotime,
      split by grouping condition, WNN.
      PNG format

  umap_spl_cnd_rd_wnnumap_plot_pdf:
    type: File?
    outputBinding:
      glob: "*_umap_spl_cnd_rd_wnnumap.pdf"
    doc: |
      UMAP, colored by pseudotime,
      split by grouping condition, WNN.
      PDF format

  ucsc_cb_config_data:
    type: Directory?
    outputBinding:
      glob: "*_cellbrowser"
    doc: |
      Directory with UCSC Cellbrowser
      configuration data.

  ucsc_cb_html_data:
    type: Directory?
    outputBinding:
      glob: "*_cellbrowser/html_data"
    doc: |
      Directory with UCSC Cellbrowser
      html data.

  ucsc_cb_html_file:
    type: File?
    outputBinding:
      glob: "*_cellbrowser/html_data/index.html"
    doc: |
      HTML index file from the directory
      with UCSC Cellbrowser html data.

  seurat_data_rds:
    type: File
    outputBinding:
      glob: "*_data.rds"
    doc: |
      Reduced Seurat data in RDS format

  seurat_data_h5seurat:
    type: File?
    outputBinding:
      glob: "*_data.h5seurat"
    doc: |
      Reduced Seurat data in h5seurat format

  seurat_data_h5ad:
    type: File?
    outputBinding:
      glob: "*_data.h5ad"
    doc: |
      Reduced Seurat data in h5ad format

  stdout_log:
    type: stdout

  stderr_log:
    type: stderr


baseCommand: ["sc_rna_trajectory.R"]

stdout: sc_rna_trajectory_stdout.log
stderr: sc_rna_trajectory_stderr.log


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf


label: "Single-cell RNA-Seq Trajectory Analysis"
s:name: "Single-cell RNA-Seq Trajectory Analysis"
s:alternateName: "Aligns cells along the trajectory defined based on PCA or other dimensionality reduction"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows/master/tools/sc-rna-trajectory.cwl
s:codeRepository: https://github.com/Barski-lab/workflows
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
  Single-cell RNA-Seq Trajectory Analysis

  Aligns cells along the trajectory defined
  based on PCA or other dimensionality reduction


s:about: |
  usage: sc_rna_trajectory.R [-h] --query QUERY
                                            [--reduction REDUCTION]
                                            [--dimensions [DIMENSIONS [DIMENSIONS ...]]]
                                            --source SOURCE
                                            [--barcodes BARCODES]
                                            [--start START] [--ngenes NGENES]
                                            [--pdf] [--verbose] [--h5seurat]
                                            [--h5ad] [--cbbuild]
                                            [--output OUTPUT]
                                            [--theme {gray,bw,linedraw,light,dark,minimal,classic,void}]
                                            [--cpus CPUS] [--memory MEMORY]

  Single-cell RNA-Seq Trajectory Analysis

  optional arguments:
    -h, --help            show this help message and exit
    --query QUERY         Path to the RDS file to load Seurat object from. This
                          file should include genes expression information
                          stored in the RNA assay and dimensionality reduction
                          specified in the --reduction parameter.
    --reduction REDUCTION
                          Dimensionality reduction to be used in the trajectory
                          analysis. Default: pca
    --dimensions [DIMENSIONS [DIMENSIONS ...]]
                          Dimensionality to use (from 1 to 50). If single value
                          N is provided, use from 1 to N dimensions. If multiple
                          values are provided, subset to only selected
                          dimensions. May fail if user specified more dimensions
                          than it was available in the selected --reduction.
                          Default: use all available dimensions
    --source SOURCE       Column from the metadata of the loaded Seurat object
                          to select clusters from
    --barcodes BARCODES   Path to the TSV/CSV file to optionally prefilter and
                          extend Seurat object metadata be selected barcodes.
                          First column should be named as 'barcode'. If file
                          includes any other columns they will be added to the
                          Seurat object metadata ovewriting the existing ones if
                          those are present. Default: all cells used, no extra
                          metadata is added
    --start START         Value from the metadata column defined with --source
                          parameter to set the starting point for the
                          trajectory. Default: defined automatically
    --ngenes NGENES       Number of the most predictive genes to be shows on the
                          gene expression heatmap. Default: 50
    --pdf                 Export plots in PDF. Default: false
    --verbose             Print debug information. Default: false
    --h5seurat            Save Seurat data to h5seurat file. Default: false
    --h5ad                Save Seurat data to h5ad file. Default: false
    --cbbuild             Export results to UCSC Cell Browser. Default: false
    --output OUTPUT       Output prefix. Default: ./sc
    --theme {gray,bw,linedraw,light,dark,minimal,classic,void}
                          Color theme for all generated plots. Default: classic
    --cpus CPUS           Number of cores/cpus to use. Default: 1
    --memory MEMORY       Maximum memory in GB allowed to be shared between the
                          workers when using multiple --cpus. Default: 32