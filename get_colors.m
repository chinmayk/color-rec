
data_dir = uigetdir('data');
input_file = uigetfile('./*.*');
inFile = fopen(input_file);

while(~feof(inFile))
    term = fgetl(inFile)
    image_dir = strcat(data_dir, '/', term, '/')
    outfile = strcat(data_dir, '/',term, '_results')
    outFid = fopen(outfile, 'w');
    fprintf(outFid, 'R\t G\t B\t L\t A\t B\n');
    jpgs = dir(strcat(image_dir, '*.jpg'))
    for i = 1:size(jpgs,1)
        imgFile = strcat(image_dir, jpgs(i).name)
        fprintf(outFid, '# %s\n', imgFile);
        rgb = imread(imgFile);
        lab = RGB2Lab(rgb);
        rs = reshape(rgb(:,:,1)',[], 1);
        gs = reshape(rgb(:,:,2)',[], 1);
        bs = reshape(rgb(:,:,3)',[], 1);
        
        ls = reshape(lab(:,:,1)',[], 1);
        as = reshape(lab(:,:,2)',[], 1);
        b_labs = reshape(lab(:,:,3)',[], 1);
        
        results = [rs'; gs';bs'; ls'; as'; b_labs'];
        fprintf(outFid, '%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',results);
        
    end
    fclose(outFid);
end