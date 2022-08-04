classdef SchurLower < handle
    % a collection of utilities for a lower triangular schur decomposition of A
    % Q, T where Q is uinitary, T is quasi-lower triangular, and
    % A == Q * T * Q'.
    %
    % columns of Q are orthonormal Schur bases
    
    methods(Static)
        function check_A(A, Q, T)
            assert(norm(A - Q * T * Q', 'fro') < 1e-4);
        end
        
        function check2(Q1, T1, Q2, T2)
            assert(norm(Q2 * T2 * Q2' - Q1 * T1 * Q1', 'fro') < 1e-4);
        end
        
        function [Q, T] = schur(A, varargin)
            % returns lower triangular version of Schur decomposition, satisfying
            % Q * T * Q' == X, columns of Q are Schur bases

            [Qu, Tu] = schur(A, varargin{:});
            [Q, T] = SchurLower.upper_to_lower(Qu, Tu);
            SchurLower.check_A(A, Q, T);
        end
        
        function [Qu, Tu] = lower_to_upper(Ql, Tl)
            R = flipud(eye(size(Tl)));
            Tu = R' * Tl * R';
            Qu = Ql * R;

            SchurLower.check2(Ql, Tl, Qu, Tu);
        end
        
        function [Qu, Tu] = upper_to_lower(Ql, Tl)
            R = flipud(eye(size(Tl)));
            Tu = R' * Tl * R';
            Qu = Ql * R;

            SchurLower.check2(Ql, Tl, Qu, Tu);
        end
        
        function E = ordeig(T)
            % equivalent of ordeig but for lower triangular
            % note that the ordering starts at the lower right corner and proceeds up and to the left though
            R = flipud(eye(size(T)));
            T = R' * T * R';

            E = ordeig(T);
        end
        
        function [Qs, Ts] = ordschur(Q, T, varargin)
            % exactly like ord but for lower triangular T produced by schur_lower_real
            [Qu, Tu] = SchurLower.lower_to_upper(Q, T);

            [Qsu, Tsu] = ordschur(Qu, Tu, varargin{:});

            [Qs, Ts] = SchurLower.upper_to_lower(Qsu, Tsu);
            
            SchurLower.check2(Q, T, Qs, Ts);
        end
        
        function [Qs, Ts] = reorder_schur(Q, T, new_evals_order)
            % reorders eigenvalues using ordshur. ordeig(Qs) == ordeig(Q)(new_evals_order).
            % Thus new_evals_order(1) specifies which entry of ordeig(Q) will appear in the lower right.
           
            N = size(T, 1);
            rank = nan(N, 1);
            
            for iE = 1:N
                rank(new_evals_order(iE)) = N-iE+1; % higher rank for lower iE
            end
            
            [Qs, Ts] = SchurLower.ordschur(Q, T, rank);
        end
        
        function [Qs, Ts] = reorder_schur_by_set(Q, T, new_set_order)
            % reorders eigenvalues using ordshur. split_by_eigenvalue(Qs) == split_by_eigenvalue(Q)(new_evals_order).
            evals = SchurLower.split_by_eigenvalue(Q, T);
            
            % but we need to expand this into a rank ordering for ordschur
            % where the first entries get the highest rank
            N = size(T, 1);
            E = numel(evals);
            rank = cell(E, 1);
            for iE = 1:E
                nThis = numel(evals{iE});
                this_pos = find(new_set_order == iE);
                rank{iE} = repmat(N - this_pos + 1, nThis, 1);
            end
            rank = cat(1, rank{:});
            [Qs, Ts] = SchurLower.ordschur(Q, T, rank);
        end

        function [evals, schur_vecs, evecs, col_inds, ordeig_inds] = split_by_eigenvalue(Q, T)
            % splitting into individual eigenvalues / pairs
            % Q, T are N x N matrices
            % evals, schur_vecs, evecs, ordeig_inds are E x 1 cells where E is the number of eigenvalues / pairs, E <= N
            % schur_vecs will contain the N x {1,2} corresponding columns of Q
            % evecs will contain the N x {1, 2} corresponding eigenvectors (or vectors that span the plane). Note that within each cell, the vectors will be orthonormalized
            % each ordeig_inds{iE} will contain the index or pair of indices into the list of eigenvalues returned by orgeig (1 is bottom right, N is top left)
            
            N = size(T, 1);

            [evals, schur_vecs, evecs, col_inds, ordeig_inds] = deal(cell(N, 1)); % we'll truncate later
            
            % compute eigenvalues / real eigenvectors using eig
            A = Q * T * Q';
            
            [Vc, Dc] = eig(A);
            [V, ~] = cdf2rdf(Vc, Dc);
            eig_evals = diag(Dc);
            
            schur_eig = ordeig_lower(T);
            
            % match up each eig from ordeig to its corresponding partner in eig_evals
            matched = false(N, 1);
            eig_evals_index = nan(N, 1);
            for iE = 1:N
                cind = N - iE + 1;
                delta = abs(schur_eig(iE) - eig_evals);
                dotp = V' * Q(:, cind);
                mask_this = ~matched & delta < 1e-4;
                if nnz(mask_this) == 1
                    match = find(mask_this);
                elseif nnz(mask_this) == 0
                    error('Could not find corresponding eigenvalue, check T is correct?');
                else
                    % find largest overlap with eigenvector
                    dotp(matched) = NaN;
                    [~, match] = max(dotp .* mask_this, [], 'omitnan');
                end
                
                eig_evals_index(iE) = match;
                matched(match) = true;
            end
            
            % reorder the columns of V so that they match the Schur decomposition ordering
            V_reordered = V(:, eig_evals_index);
            
            iE = 1; % current slot in evals, ...
            iC = 1; % current column
            while iC <= N
                if ~isreal(schur_eig(iC))
                    % complex eigenvalue pair -> include off diagonal terms
                    inds = (iC:iC+1)';
                    iC = iC + 2;
                else
                    inds = iC;
                    iC = iC + 1;
                end
                cinds = N - inds + 1; % remember that Q is in reverse order (with schur basis 1 the right-most column)
                
                evals{iE} = schur_eig(inds);
                schur_vecs{iE} = Q(:, cinds);
                evecs{iE} = orth(V_reordered(:, inds)); % orthonormalize within each set of eigenvectors
                ordeig_inds{iE} = inds;
                col_inds{iE} = cinds;
                iE = iE + 1;
            end
            
            E = iE - 1;
            take = (1:E)'; % send in reverse order since the ordering is from bottom right to top left
            evals = evals(take);
            schur_vecs = schur_vecs(take);
            evecs = evecs(take);
            ordeig_inds = ordeig_inds(take);
            col_inds = col_inds(take);
        end
        
        function [Qr, Tr] = reorder_by_projection_norm(Q, T, vecs, mode)
            % this implements a special kind of Schur reordering (using ordschur)
            % where the goal is to have the first Schur basis (in the last row) have the 
            % projection of vec (or sum over these norms if vecs has multiple columns) be maximal 
            % (or minimal, depending on mode) norm. And then the projection norms should monotonically 
            % decrease (or increase) for successive Schur bases.
           
            if nargin < 4
                mode = "max";
            end
            if strcmp(mode, "max")
                maximize = true;
            elseif strcmp(mode, "min")
                maximize = false;
            else
                error('Mode must be "max" or "min"');
            end
            
            N = size(T, 1);
            [evals, ~, evecs] = SchurLower.split_by_eigenvalue(Q, T);
            E = numel(evals); % number of eigenvalue-sets (pairs count as one)
           
            evals_used = false(E, 1);
            evals_order = nan(E, 1);
            total_proj_ordered = nan(E, 1);
            
            for iS = 1:E
                % pick the max / min projection of the remaining evecs
                proj = compute_vec_proj(vecs, evecs, ~evals_used);
                if maximize
                    [tproj, ind] = max(proj, [], 'omitnan');
                else
                    [tproj, ind] = min(proj, [], 'omitnan');
                end

                % now we take that eigenvalue-set next
                evals_order(iS) = ind;
                evals_used(ind) = true;
                total_proj_ordered(iS) = tproj;
                
                % and orthogonalize the remaining eigenvectors against it
                selected_evec = evecs{ind};
                for iE = 1:E
                    if ~evals_used(iE)                        
                        evecs{iE} = orthogonalize_against(evecs{iE}, selected_evec);
                        
%                         pre = proj(iE);
%                         post = compute_vec_proj(vecs, evecs(iE), true);
%                         debug('ev %2d: pre: %.0f, post %.0f\n', iE, pre, post);
                    end
                end
                vecs = orthogonalize_against(vecs, selected_evec);
            end
            
            % now we have reordered the entries of evals
            %evals_sorted = cat(1, evals{evals_order});
            
            % but we need to expand this into a rank ordering for ordschur
            % where the first entries get the highest rank
            rank = cell(E, 1);
            for iE = 1:E
                nThis = numel(evals{iE});
                this_pos = find(evals_order == iE);
                rank{iE} = repmat(E - this_pos + 1, nThis, 1);
            end
            rank = cat(1, rank{:});
            [Qr, Tr] = SchurLower.ordschur(Q, T, rank);
            
            % compute the total projected variance of vecs onto each evecs
            function proj = compute_vec_proj(vecs, evecs, mask)
                nE = numel(evecs);
                ssq = @(x) sum(x(:).^2, 'omitnan');
                proj = nan(nE, 1);
                for i = 1:nE
                    projMat = @(M) M * (M'*M)^(-1)* M';
                    proj(i) = ssq(projMat(evecs{i}) * vecs); % ({1,2} * N) x (N x V) = {1,2} x V vectors
                end
                proj(~mask) = NaN;
            end
            
            function in = orthogonalize_against(in, against)
                % in and against are both N x ... sets of column vectors
                projMat = @(M) M * (M'*M)^(-1)* M';
                in = in - projMat(against)*in;
            end
        end
        
        function [proj, col_inds, ordeig_inds] = compute_projection_norm_by_basis_set(Q, T, vecs)
            % computes the projection norm of vec into each Schur basis or pair of bases
            [evals, schur_vecs, ~, col_inds, ordeig_inds] = SchurLower.split_by_eigenvalue(Q, T);
            
            E = numel(evals);
            proj = nan(E, 1);
            ssq = @(x) sum(x(:).^2, 'omitnan');
            for iE = 1:E
                proj(iE) = ssq(schur_vecs{iE}' * vecs); % ({1,2} * N) x (N x V) = {1,2} x V vectors
            end
        end
        
        function [Z, Ztotal] = aggregate_total_across_basis_set(Q, T, args)
            % sums the absolute value of T within the basis sets specified by col_inds, 
            % which is nBasisSets cell of {1 or 2 column idx}, the output of split_by_eigenvalue.

            arguments
                Q (:, :)
                T (:, :)
                args.add_in_quadrature (1, 1) logical = true;
                args.col_inds (:, 1) cell = {}; % required if Q not provided
                args.include_diag = true;
                args.nan_empty = true;
            end

            if isempty(Q)
                assert(~isempty(args.col_inds));
                col_inds = args.col_inds;
            else
                [~, ~, ~, col_inds] = SchurLower.split_by_eigenvalue(Q, T);
            end

            E = numel(col_inds);
            Z = zeros(E, E, 'single');
            for i = 1:E
                for j = i:E
                    if ~args.include_diag && i == j
                        continue;
                    end
                    if args.add_in_quadrature
                        Z(i, j) = sqrt(sum(T(col_inds{i}, col_inds{j}).^2, 'all', 'omitnan'));
                    else
                        Z(i, j) = sum(abs(T(col_inds{i}, col_inds{j})), 'all', 'omitnan');
                    end
                end
            end

            % deal with reverse ordering in lower-triangular Schur T
            R = flipud(eye(size(Z)));
            Z = R' * Z * R';

            if args.nan_empty
                if args.include_diag
                    mask = tril(true(E, E));
                else
                    mask = tril(true(E, E)) & ~eye(E, E);
                end
                Z(~mask) = NaN;
            end

            if args.add_in_quadrature
                Ztotal = sqrt(sum(Z.^2, 2, 'omitnan'));
            else
                Ztotal = sum(Z, 2, 'omitnan');
            end
        end

        % splitting into lower and diagonal parts
        function mask = mask_lower_tri(T)
            N = size(T, 1);
            mask = tril(true(N, N)) & ~SchurLower.mask_diag(T);
        end
        
        function mask = mask_diag(T, eig_mask)
            N = size(T, 1);
            if nargin < 2
                eig_mask = true(N, 1);
            end

            mask = false(N, N);

            % SchurLower.ordeig returns eigenvalues from the bottom right up to top left
            % so we want to iterate in reverse order
            eig = flipud(SchurLower.ordeig(T));
            iE = 1;
            while iE <= N
                if ~isreal(eig(iE))
                    % complex eigenvalue pair
                    if eig_mask(iE) || eig_mask(iE+1)
                        % include off diagonal terms
                        mask(iE:iE+1, iE:iE+1) = true;
                    end
                    iE = iE + 2; % skip my conjugate pair
                else
                    % real eigenvalue
                    if eig_mask(iE)
                        % include only diagonal term
                        mask(iE, iE) = true;
                    end
                    iE = iE + 1;
                end
            end
        end
        
        function [D, L] = split_tri(T)
            [D, L] = deal(zeros(size(T), 'like', T));
            
            mask_diag = SchurLower.mask_diag(T);
            D(mask_diag) = T(mask_diag);
            
            mask_lower = SchurLower.mask_lower_tri(T);
            L(mask_lower) = T(mask_lower);
        end
    end
    
    methods(Static) % plotting
        function h = plot_lower_tri(T, varargin)
            mask = SchurLower.mask_lower_tri(T);
            T(~mask) = NaN;
            
            h = pmatbal(T, varargin{:});
        end
    end
end