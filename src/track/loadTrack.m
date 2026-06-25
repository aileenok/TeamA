function track = loadTrack(filename, sourceType)
% loadTrack
% Generic track loading interface.
%
% Inputs:
%   filename   : path to the track CSV file
%   sourceType : data source type, e.g. "TUM"
%
% Output:
%   track      : standardized track structure

arguments
    filename {mustBeTextScalar}
    sourceType {mustBeTextScalar} = "TUM"
end

sourceType = upper(string(sourceType));

switch sourceType
    case "TUM"
        track = loadTUMTrack(filename);

    otherwise
        error("Unsupported track source type: %s", sourceType);
end

end