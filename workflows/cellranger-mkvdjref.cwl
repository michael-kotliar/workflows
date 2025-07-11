cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement


"sd:upstream":
  genome_indices:
  - "genome-indices.cwl"


inputs:

  alias:
    type: string
    label: "Analysis name"
    sd:preview:
      position: 1

  genome_fasta_file:
    type: File
    label: "Genome type"
    doc: |
      Genome type to be used for
      generating reference genome
      indices
    "sd:upstreamSource": "genome_indices/fasta_output"
    "sd:localLabel": true

  annotation_gtf_file:
    type: File
    "sd:upstreamSource": "genome_indices/annotation_gtf"

  memory_limit:
    type: int?
    default: 20
    label: "Maximum memory used (GB)"
    doc: |
      Maximum memory used (GB).
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

  indices_folder:
    type: Directory
    outputSource: cellranger_mkvdjref/indices_folder
    label: Cell Ranger V(D)J genome indices
    doc: |
      Cell Ranger V(D)J-compatible reference folder.
      This folder will include V(D)J segment FASTA file.

  unmasked_fasta:
    type: File
    outputSource: unmask_fasta/unmasked_fasta
    label: "Unmasked genome FASTA file"
    doc: |
      Indexed unmasked reference genome FASTA file

  stdout_log:
    type: File
    outputSource: cellranger_mkvdjref/stdout_log
    label: stdout log generated by cellranger mkvdjref
    doc: |
      stdout log generated by cellranger mkvdjref

  stderr_log:
    type: File
    outputSource: cellranger_mkvdjref/stderr_log
    label: stderr log generated by cellranger mkvdjref
    doc: |
      stderr log generated by cellranger mkvdjref


steps:

  unmask_fasta:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      hints:
      - class: DockerRequirement
        dockerPull: biowardrobe2/samtools:v1.11
      inputs:
        script:
          type: string?
          default: |
            cat $0 | awk '{if($0 ~ /^>/) print $0; else print toupper($0)}' > genome.fa
            samtools faidx genome.fa
          inputBinding:
            position: 1
        genome_fasta_file:
          type: File
          inputBinding:
            position: 2
      outputs:
        unmasked_fasta:
          type: File
          outputBinding:
            glob: "genome.fa"
          secondaryFiles:
          - .fai
      baseCommand: ["bash", "-c"]
    in:
      genome_fasta_file: genome_fasta_file
    out:
    - unmasked_fasta

  cellranger_mkvdjref:
    run: ../tools/cellranger-mkvdjref.cwl
    in:
      genome_fasta_file: unmask_fasta/unmasked_fasta
      annotation_gtf_file: annotation_gtf_file
      threads:
        source: threads
        valueFrom: $(parseInt(self))
      memory_limit: memory_limit
      output_folder_name:
        default: "cellranger_vdj_ref"
    out:
    - indices_folder
    - stdout_log
    - stderr_log


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf

label: "Cell Ranger Reference (VDJ)"
s:name: "Cell Ranger Reference (VDJ)"
s:alternateName: "Builds a reference genome of a selected species for V(D)J contigs assembly and clonotype calling"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows-datirium/master/workflows/cellranger-mkvdjref.cwl
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
  Cell Ranger Reference (VDJ)

  Builds a reference genome of a selected species for V(D)J
  contigs assembly and clonotype calling. The results of this
  workflow are used in “Cell Ranger Count (RNA+VDJ)” pipeline.