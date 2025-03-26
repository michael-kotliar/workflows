cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
    expressionLib:
    - var split_features = function(line) {
          function get_unique(value, index, self) {
            return self.indexOf(value) === index && value != "";
          }
          var splitted_line = line?line.split(/[\s,]+/).filter(get_unique):null;
          return (splitted_line && !!splitted_line.length)?splitted_line:null;
      };
    - var split_by_comma = function(line) {
          function get_unique(value, index, self) {
            return self.indexOf(value) === index && value != "";
          }
          var splitted_line = line?line.split(/,+/).filter(get_unique):null;
          return (splitted_line && !!splitted_line.length)?splitted_line:null;
      };


"sd:upstream":
  sc_tools_sample:
  - "sc-rna-cluster.cwl"
  - "sc-ctype-assign.cwl"
  - "sc-wnn-cluster.cwl"
  - "sc-rna-da-cells.cwl"
  - "sc-rna-azimuth.cwl"


inputs:

  alias:
    type: string
    label: "Analysis name"
    sd:preview:
      position: 1

  query_data_rds:
    type: File
    label: "Single-cell Analysis with Clustered RNA-Seq Datasets"
    doc: |
      Analysis that includes single-cell
      multiome RNA and ATAC-Seq or just
      RNA-Seq datasets run through either
      "Single-Cell Manual Cell Type
      Assignment", "Single-Cell RNA-Seq
      Cluster Analysis", "Single-Cell
      WNN Cluster Analysis", or "Single-Cell
      RNA-Seq Reference Mapping" pipeline
      at any of the processing stages.
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
      - "REF"                                # from the sc-rna-azimuth.cwl pipeline
    default: "RNA"
    label: "Dimensionality reduction"
    doc: |
      Dimensionality reduction to be used
      for generating UMAP plots.

  groupby:
    type: string?
    default: null
    label: "Subsetting category (optional)"
    doc: |
      Single cell metadata column to group
      cells for optional subsetting before
      running differential expression analysis.
      To group cells by dataset, use "dataset".
      Custom groups can be defined based on
      any single cell metadata added through
      the "Datasets metadata (optional)" or
      "Selected cell barcodes (optional)"
      inputs. Default: do not subset cells

  subset:
    type: string?
    default: null
    label: "Subsetting values (optional)"
    doc: |
      Comma separated list of values from
      the single cell metadata column
      selected in "Subsetting category
      (optional)" input. Ignored if grouping
      category is not provided. Default: do
      not subset cells

  splitby:
    type: string
    label: "Comparison category"
    doc: |
      Single cell metadata column to split
      cells into two comparison groups before
      running differential expression analysis.
      To split cells by dataset, use "dataset".
      Custom groups can be defined based on
      any single cell metadata added through
      the "Datasets metadata (optional)" or
      "Selected cell barcodes (optional)"
      inputs. The direction of comparison is
      always "Second comparison group" vs
      "First comparison group".

  first_cond:
    type: string
    label: "First comparison group"
    doc: |
      Value from the single cell metadata
      column selected in "Comparison category"
      input to define the first group of cells
      for differential expression analysis.

  second_cond:
    type: string
    label: "Second comparison group"
    doc: |
      Value from the single cell metadata
      column selected in "Comparison category"
      input to define the second group of cells
      for differential expression analysis.

  analysis_method:
    type:
    - "null"
    - type: enum
      symbols:
      - "wilcoxon"                                      # (wilcox) Wilcoxon Rank Sum test
      - "likelihood-ratio"                              # (bimod) Likelihood-ratio test
      - "t-test"                                        # (t) Student's t-test
      - "negative-binomial (batch correction)"          # (negbinom) Negative Binomial Generalized Linear Model (supports --batchby)
      - "poisson (batch correction)"                    # (poisson) Poisson Generalized Linear Model (supports --batchby)
      - "logistic-regression (batch correction)"        # (LR) Logistic Regression (supports --batchby)
      - "mast (batch correction)"                       # (MAST) MAST package (supports --batchby)
      - "deseq (pseudo bulk, batch correction)"         # DESeq2 Wald test on pseudobulk aggregated gene expression
      - "deseq-lrt (pseudo bulk, batch correction)"     # DESeq2 LRT test on pseudobulk aggregated gene expression
    default: "wilcoxon"
    label: "Statistical test"
    doc: |
      Statistical test to use in the
      differential expression analysis. If
      set to "deseq" or "deseq-lrt", gene
      expression will be aggregated to the
      pseudo bulk form per dataset. Othwerwise,
      analysis will be run on the cells level.
      If "deseq" is selected, the pair-wise
      Wald test will be used. For "deseq-lrt",
      the Likelihood Ratio Test will be applied
      between design and reduced formulas. The
      reduced formula will look like "~1" if
      grouping by batches is omitted or will be
      set to the category defined in "Batch
      correction (if supported)" input.

  batchby:
    type: string?
    default: null
    label: "Batch correction (if supported)"
    doc: |
      Value from the single cell metadata
      column to be used for batch effect
      modeling if the selected "Statistical
      test" supports it (otherwise the
      workflow will exit with error). For
      "deseq" and "deseq-lrt" tests batch
      modeling will result in adding it
      into the design formula. For
      negative-binomial, poisson,
      logistic-regression, or mast tests
      grouping by batches will be used as
      a latent variable in the "FindMarkers"
      function.

  exclude_pattern:
    type: string?
    default: null
    label: "Exclude genes"
    doc: |
      Regex pattern to identify and exclude
      specific genes from the differential
      expression analysis (not case-sensitive).
      If any of these genes were also provided
      in "Genes of interest" input, they will
      be excluded from that list as well.

  maximum_padj:
    type: float?
    default: 0.05
    label: "Maximum adjusted p-value"
    doc: |
      Maximum adjusted p-value threshold for
      selecting differentially expressed genes
      to be visualized on the heatmap.

  minimum_pct:
    type: float?
    default: 0.1
    label: "Minimum fraction of cells where a gene should be expressed"
    doc: |
      Minimum fraction of cells in either of
      the two tested conditions where the gene
      should be expressed to be included into
      analysis.

  minimum_logfc:
    type: float?
    default: 0.585
    label: "Minimum log2 fold change absolute value"
    doc: |
      In the exploratory visualization part of
      the analysis output only differentially
      expressed genes with log2 Fold Change
      not smaller than this value.
      Default: 0.585 (1.5 folds)

  enable_clustering:
    type: boolean?
    default: false
    label: "Cluster gene expression heatmap"
    doc: |
      Apply hierarchical (HOPACH) clustering
      on the normalized read counts for the
      exploratory visualization part of the
      analysis. If the "Statistical test"
      input is set to "deseq" or "deseq-lrt",
      clustering will be performed for both
      rows (genes) and columns (pseudo bulk
      gene expression per dataset). For all
      other statistical tests, clustering will
      be performed only by rows (genes).
      Default: clustering not enabled

  genes_of_interest:
    type: string?
    default: null
    label: "Genes of interest"
    doc: |
      Comma or space separated list of genes
      of interest to visualize expression
      on the generated volcano, violin, and
      UMAP plots.
      Default: None

  datasets_metadata:
    type: File?
    label: "Datasets metadata (optional)"
    doc: |
      If the selected single-cell analysis
      includes multiple aggregated datasets,
      each of them can be assigned to a
      separate group by one or multiple
      categories. This can be achieved by
      providing a TSV/CSV file with
      "library_id" as the first column and
      any number of additional columns with
      unique names, representing the desired
      grouping categories.

  barcodes_data:
    type: File?
    label: "Selected cell barcodes (optional)"
    doc: |
      A TSV/CSV file to optionally prefilter
      the single cell data by including only
      the cells with the selected barcodes.
      The provided file should include at
      least one column named "barcode", with
      one cell barcode per line. All other
      columns, except for "barcode", will be
      added to the single cell metadata loaded
      from "Single-cell Analysis with Clustered
      RNA-Seq Datasets" and can be utilized in
      the current or future steps of analysis.

  export_html_report:
    type: boolean?
    default: true
    label: "Show HTML report"
    doc: |
      Export tehcnical report in HTML format.
      Default: true
    "sd:layout":
      advanced: true

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
    label: "Plots color theme"
    doc: |
      Color theme for all plots saved
      as PNG files.
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
    label: "Cores/CPUs"
    doc: |
      Parallelization parameter to define the
      number of cores/CPUs that can be utilized
      simultaneously.
      Default: 4
    "sd:layout":
      advanced: true


outputs:

  mds_plot_html:
    type: File?
    outputSource: de_pseudobulk/mds_plot_html
    label: "MDS Plot"
    doc: |
      MDS plot of pseudobulk aggregated
      not filtered normalized reads counts
      in HTML format
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  diff_expr_genes:
    type: File
    outputSource: de_pseudobulk/diff_expr_genes
    label: "Differentially expressed genes"
    doc: |
      Not filtered by adjusted p-value
      differentially expressed genes in
      TSV format
    "sd:visualPlugins":
    - syncfusiongrid:
        tab: "Diff. expressed genes"
        Title: "Differentially expressed genes"
    - queryRedirect:
        tab: "Overview"
        label: "Volcano Plot"
        url: "https://scidap.com/vp/volcano"
        query_eval_string: "`data_file=${this.getSampleValue('outputs', 'diff_expr_genes')}&data_col=gene&x_col=log2FoldChange&y_col=padj`"

  xpr_htmp_html:
    type: File?
    outputSource: de_pseudobulk/xpr_htmp_html
    label: "Gene Expression Heatmap"
    doc: |
      Gene expression heatmap.
      Filtered by adjusted p-value and log2FC;
      optionally subsetted to the specific groups.
      HTML format.
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  sc_report_html_file:
    type: File?
    outputSource: de_pseudobulk/sc_report_html_file
    label: "Analysis log"
    doc: |
      Tehcnical report.
      HTML format.
    "sd:visualPlugins":
    - linkList:
        tab: "Overview"
        target: "_blank"

  cell_cnts_plot_png:
    type: File?
    outputSource: de_pseudobulk/cell_cnts_plot_png
    label: "Number of cells per dataset or comparison group"
    doc: |
      Number of cells per dataset or
      tested condition. Colored by tested
      condition; optionally subsetted to
      the specific group.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "QC"
        Caption: "Number of cells per dataset or comparison group"

  umap_spl_tst_plot_png:
    type: File?
    outputSource: de_pseudobulk/umap_spl_tst_plot_png
    label: "UMAP colored by selected for analysis cells"
    doc: |
      UMAP colored by selected for
      analysis cells. Split by tested
      condition; optionally subsetted
      to the specific group.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "QC"
        Caption: "UMAP colored by selected for analysis cells"

  pca_1_2_plot_png:
    type: File?
    outputSource: de_pseudobulk/pca_1_2_plot_png
    label: "Gene expression PCA (1,2)"
    doc: |
      Gene expression PCA (1,2)
      in PNG format
    "sd:visualPlugins":
    - image:
        tab: "QC"
        Caption: "Gene expression PCA (1,2)"
  
  pca_2_3_plot_png:
    type: File?
    outputSource: de_pseudobulk/pca_2_3_plot_png
    label: "Gene expression PCA (2,3)"
    doc: |
      Gene expression PCA (2,3)
      in PNG format
    "sd:visualPlugins":
    - image:
        tab: "QC"
        Caption: "Gene expression PCA (2,3)"

  dxpr_vlcn_plot_png:
    type: File?
    outputSource: de_pseudobulk/dxpr_vlcn_plot_png
    label: "Volcano plot of differentially expressed genes"
    doc: |
      Volcano plot of differentially expressed
      genes. Highlighed genes are either provided
      by user or top 10 genes with the highest
      log2FoldChange values. PNG format
    "sd:visualPlugins":
    - image:
        tab: "Volcano plot"
        Caption: "Volcano plot of differentially expressed genes"

  xpr_htmp_plot_png:
    type: File?
    outputSource: de_pseudobulk/xpr_htmp_plot_png
    label: "Gene expression heatmap"
    doc: |
      Gene expression heatmap.
      Filtered by adjusted p-value and log2FC;
      optionally subsetted to the specific groups.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Heatmap"
        Caption: "Gene expression heatmap"

  xpr_htmp_tsv:
    type: File?
    outputSource: de_pseudobulk/xpr_htmp_tsv
    label: "Gene expression heatmap (top gene markers)"
    doc: |
      Gene expression heatmap.
      Filtered by adjusted p-value and log2FC;
      optionally subsetted to the specific groups.
      TSV format.

  xpr_htmp_gct:
    type: File?
    outputSource: de_pseudobulk/xpr_htmp_gct
    label: "Gene expression heatmap"
    doc: |
      Gene expression heatmap.
      Filtered by adjusted p-value and log2FC;
      optionally subsetted to the specific groups.
      GCT format.

  xpr_avg_plot_png:
    type: File?
    outputSource: de_pseudobulk/xpr_avg_plot_png
    label: "Average gene expression"
    doc: |
      Average gene expression plots split by dataset
      or tested condition for either user provided
      or top 10 differentially expressed genes with
      the highest log2FoldChange values.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Genes of interest"
        Caption: "Average gene expression"

  xpr_dnst_plot_png:
    type: File?
    outputSource: de_pseudobulk/xpr_dnst_plot_png
    label: "Gene expression violin plot"
    doc: |
      Gene expression violin plots for
      either user provided or top 10
      differentially expressed genes
      with the highest log2FoldChange
      values in PNG format
    "sd:visualPlugins":
    - image:
        tab: "Genes of interest"
        Caption: "Gene expression violin plot"

  xpr_per_cell_plot_png:
    type:
    - "null"
    - type: array
      items: File
    outputSource: de_pseudobulk/xpr_per_cell_plot_png
    label: "UMAP colored by gene expression"
    doc: |
      UMAP colored by gene expression.
      Split by selected criteria; optionally
      subsetted to the specific group.
      PNG format.
    "sd:visualPlugins":
    - image:
        tab: "Genes of interest"
        Caption: "UMAP colored by gene expression"

  read_counts_file:
    type: File?
    outputSource: de_pseudobulk/bulk_counts_gct
    label: "GSEA compatible bulk reads counts"
    doc: |
      GSEA compatible not filtered normalized
      reads counts aggregated to pseudobulk
      form.
      GCT format.

  phenotypes_file:
    type: File?
    outputSource: de_pseudobulk/bulk_phntps_cls
    label: "GSEA compatible phenotypes"
    doc: |
      GSEA compatible phenotypes file defined
      based on --splitby, --first, and --second
      parameters.
      CLS format.

  pdf_plots:
    type: File
    outputSource: compress_pdf_plots/compressed_folder
    label: "Compressed folder with all PDF plots"
    doc: |
      Compressed folder with all PDF plots.

  de_pseudobulk_human_log:
    type: File?
    outputSource: de_pseudobulk/human_log
    label: "Human readable error log"
    doc: |
      Human readable error log
      from the de_pseudobulk step.

  de_pseudobulk_stdout_log:
    type: File
    outputSource: de_pseudobulk/stdout_log
    label: "Output log"
    doc: |
      Stdout log from the de_pseudobulk step.

  de_pseudobulk_stderr_log:
    type: File
    outputSource: de_pseudobulk/stderr_log
    label: "Error log"
    doc: |
      Stderr log from the de_pseudobulk step.


steps:

  de_pseudobulk:
    run: ../tools/sc-rna-de-pseudobulk.cwl
    in:
      query_data_rds: query_data_rds
      reduction:
        source: query_reduction
        valueFrom: |
          ${
            if (self == "RNA") {
              return "rnaumap";
            } else if (self == "ATAC") {
              return "atacumap";
            } else if (self == "WNN") {
              return "wnnumap";
            } else {
              return "refumap";
            }
          }
      datasets_metadata: datasets_metadata
      barcodes_data: barcodes_data
      groupby:
        source: groupby
        valueFrom: |
          ${
            if (self == "dataset") {
              return "new.ident";
            } else if (self == "") {
              return null;
            } else {
              return self;
            }
          }
      subset:
        source: subset
        valueFrom: $(split_by_comma(self))
      splitby:
        source: splitby
        valueFrom: |
          ${
            if (self == "dataset") {
              return "new.ident";
            } else {
              return self;
            }
          }
      first_cond: first_cond
      second_cond: second_cond
      analysis_method:
        source: analysis_method
        valueFrom: $(self.split(" ")[0])
      batchby:
        source: batchby
        valueFrom: $(self==""?null:self)            # safety measure
      maximum_padj: maximum_padj
      minimum_pct: minimum_pct
      minimum_logfc: minimum_logfc
      genes_of_interest:
        source: genes_of_interest
        valueFrom: $(split_features(self))
      exclude_pattern:
        source: exclude_pattern
        valueFrom: $(self==""?null:self)            # safety measure
      cluster_method:
        source:
        - enable_clustering
        - analysis_method
        valueFrom: |
          ${
            if (self[0]) {
              if (self[1].includes("deseq")) {
                return "both";
              } else {
                return "row";
              }
            } else {
              return null;
            }
          }
      row_distance:
        default: "cosangle"
      column_distance:
        default: "euclid"
      center_row:
        default: true
      export_pdf_plots:
        default: true
      color_theme: color_theme
      verbose:
        default: true
      parallel_memory_limit:
        default: 32
      vector_memory_limit:
        default: 128
      export_html_report: export_html_report
      threads:
        source: threads
        valueFrom: $(parseInt(self))
    out:
      - umap_spl_tst_plot_png
      - cell_cnts_plot_png
      - pca_1_2_plot_png
      - pca_2_3_plot_png
      - dxpr_vlcn_plot_png
      - xpr_avg_plot_png
      - xpr_dnst_plot_png
      - xpr_per_cell_plot_png
      - xpr_htmp_plot_png
      - xpr_htmp_tsv
      - mds_plot_html
      - diff_expr_genes
      - bulk_counts_gct
      - bulk_phntps_cls
      - xpr_htmp_gct
      - xpr_htmp_html
      - all_plots_pdf
      - sc_report_html_file
      - human_log
      - stdout_log
      - stderr_log

  folder_pdf_plots:
    run: ../tools/files-to-folder.cwl
    in:
      input_files:
        source:
        - de_pseudobulk/all_plots_pdf
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

label: "Single-Cell RNA-Seq Differential Expression Analysis"
s:name: "Single-Cell RNA-Seq Differential Expression Analysis"
s:alternateName: "Single-Cell RNA-Seq Differential Expression Analysis"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows-datirium/master/workflows/sc-rna-de-pseudobulk.cwl
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
  Single-Cell RNA-Seq Differential Expression Analysis

  Identifies differentially expressed genes between any
  two groups of cells, optionally aggregating gene
  expression data from single-cell to pseudobulk form.