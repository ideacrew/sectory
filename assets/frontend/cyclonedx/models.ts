import * as cdx from "@cyclonedx/cyclonedx-library";

/*
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends Array<infer I>
    ? Array<DeepPartial<I>>
    : DeepPartial<T[P]>
};
*/

const SeverityOrder = [
  cdx.Enums.Vulnerability.Severity.None,
  cdx.Enums.Vulnerability.Severity.Unknown,
  cdx.Enums.Vulnerability.Severity.Info,
  cdx.Enums.Vulnerability.Severity.Low,
  cdx.Enums.Vulnerability.Severity.Medium,
  cdx.Enums.Vulnerability.Severity.High,
  cdx.Enums.Vulnerability.Severity.Critical 
];

export function severitySort(s: cdx.Enums.Vulnerability.Severity) {
  return SeverityOrder.indexOf(s);
}

export type Hash = {
  alg: cdx.Enums.HashAlgorithm;
  content: string;
};

export type Rating = {
  score: number;
  severity: cdx.Enums.Vulnerability.Severity;
  method?: string;
  vector?: string;
}

export type ReferenceSource = {
  name: string;
  url: string;
}

export type Reference = {
  id: string;
  source: ReferenceSource;
};

export type AffectsRef = {
  ref: string;
}

export type Advisory = {
  url: string;
};

export type Tool = {
  name: string;
}

export type ToolSet = {
  components?: Array<Tool>;
}

export type VulnerabilityAnalysis = {
  state?: cdx.Enums.Vulnerability.AnalysisState;
  justification?: cdx.Enums.Vulnerability.AnalysisJustification;
  response?: cdx.Enums.Vulnerability.AnalysisResponse;
  detail?: string;
  firstIssued?: string;
  lastUpdated: string;
};

export type Vulnerability = {
  id: string;
  "bom-ref": string;
  description: string;
  detail?: string;
  ratings?: Array<Rating>;
  references?: Array<Reference>;
  affects?: Array<AffectsRef>;
  advisories?: Array<Advisory>;
  tools?: ToolSet;
  analysis?: VulnerabilityAnalysis;
};

export type ExternalRef = {
  type: cdx.Enums.ExternalReferenceType;
  url: string;
  hashes?: Array<Hash>;
}

export type Component = {
  name: string;
  hashes?: Array<Hash>;
  version?: string;
  purl?: string;
  cpe?: string;
  "bom-ref": string;
  description?: string;
  externalReferences: Array<ExternalRef>;
}

export type Metadata = {
  component: Component;
}

export type Bom = {
  metadata: Metadata;
  components: Array<Component>;
  vulnerabilities?: Array<Vulnerability>;
}

export function getComponentKind(comp: Component) {
  if (comp.purl) {
    const purl = comp.purl;
    if (purl.startsWith("pkg:gem/")) {
      return "Gem";
    } else if (purl.startsWith("pkg:npm/")) {
      return "NPM";
    } else if (purl.startsWith("pkg:deb/")) {
      return "Debian";
    } else if (purl.startsWith("pkg:apk/")) {
      return "Alpine";
    }
  }
  return "other";
}

const noSeverityAnalysisStates = [
  cdx.Enums.Vulnerability.AnalysisState.FalsePositive,
  cdx.Enums.Vulnerability.AnalysisState.NotAffected,
  cdx.Enums.Vulnerability.AnalysisState.Resolved,
  cdx.Enums.Vulnerability.AnalysisState.ResolvedWithPedigree
];

export function formatSeverity(vuln: Vulnerability) {
  if (vuln.analysis) {
    if (vuln.analysis.state) {
      if (noSeverityAnalysisStates.indexOf(vuln.analysis.state) > -1) {
        return cdx.Enums.Vulnerability.Severity.None;
      }
    }
  }
  if (vuln.ratings) {
    const ratings = vuln.ratings;
    if (ratings.length > 0) {
      let sortedRatings = ratings.sort((a, b) => {
        return severitySort(a.severity) - severitySort(b.severity);
      });
      return sortedRatings[0].severity;
    }
  }
  return cdx.Enums.Vulnerability.Severity.Unknown;
}